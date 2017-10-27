// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation

/**
 Process a bunch of jobs and collect the results
*/
final class JobProcessor {

    let identifier: String
    private let backendUtils: BackendUtils
    private let q_jobs: [QuantumJob]
    private let callback: ((_:String, _:[Result]) -> Void)?
    private var num_jobs: Int
    private var jobs_results: [Result] = []

    init(_ backendUtils: BackendUtils,
         _ q_jobs: [QuantumJob],
         _ callback: ((_:String, _:[Result]) -> Void)?) throws {
        self.identifier = UUID().uuidString
        self.backendUtils = backendUtils
        self.q_jobs = q_jobs
        self.callback = callback
        self.num_jobs = self.q_jobs.count
    }

    private func _job_done_callback(_ result: Result) {
        SyncLock.synchronized(self) {
            self.jobs_results.append(result)
            if self.num_jobs > 0 {
                self.num_jobs -= 1
            }
        }
        // Call the callback when all jobs have finished
        if self.num_jobs == 0 {
            SDKLogger.logInfo(SDKLogger.debugString(result))
            self.callback?(self.identifier,self.jobs_results)
        }
    }

    func submit() {
        for q_job in self.q_jobs {
            self.run_backend(q_job, self._job_done_callback)
        }
    }

    private func run_backend(_ q_job: QuantumJob, _ response: @escaping ((_:Result) -> Void)) {
        do {
            let backend_name = q_job.backend
            var qobj = q_job.qobj
            // remove condition when api gets qobj
            if self.backendUtils.local_backends().contains(backend_name) {
                if let circuits = qobj["circuits"] as? [[String:Any]] {
                    var newCircuits: [[String:Any]] = []
                    for var circuit in circuits {
                        if circuit["compiled_circuit"] == nil {
                            circuit["compiled_circuit"] = try OpenQuantumCompiler.compile(circuit["circuit"] as! String, format: "json")
                        }
                        newCircuits.append(circuit)
                    }
                    qobj["circuits"] = newCircuits
                }
                q_job._qobj = qobj
            }
            self.backendUtils.get_backend_instance(backend_name) { (backend,error) in
                if error != nil {
                    response(Result(["job_id": "0", "status": "ERROR","result": error!.localizedDescription],q_job.qobj))
                    return
                }
                backend!.run(q_job,response: response)
            }
        } catch {
            DispatchQueue.main.async {
                response(Result(["job_id": "0", "status": "ERROR","result": error.localizedDescription],q_job.qobj))
            }
        }
    }
}
