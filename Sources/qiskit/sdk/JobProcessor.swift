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
#if os(Linux)
import Dispatch
#endif

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
    private let lock = NSRecursiveLock()

    init(_ backendUtils: BackendUtils,
         _ q_jobs: [QuantumJob],
         _ callback: ((_:String, _:[Result]) -> Void)?) {
        self.identifier = UUID().uuidString
        self.backendUtils = backendUtils
        self.q_jobs = q_jobs
        self.callback = callback
        self.num_jobs = self.q_jobs.count
    }

    init() {
        self.identifier = UUID().uuidString
        self.backendUtils = BackendUtils()
        self.q_jobs = []
        self.callback = nil
        self.num_jobs = self.q_jobs.count
    }

    private func _job_done_callback(_ result: Result) {
        self.lock.lock()
        self.jobs_results.append(result)
        if self.num_jobs > 0 {
            self.num_jobs -= 1
        }
        self.lock.unlock()
        // Call the callback when all jobs have finished
        if self.num_jobs == 0 {
            SDKLogger.logInfo(SDKLogger.debugString(result))
            self.callback?(self.identifier,self.jobs_results)
        }
    }

    func submit() -> RequestTask {
        let reqTask = RequestTask()
        for q_job in self.q_jobs {
            let r = self.run_backend(q_job, self._job_done_callback)
            reqTask.add(r)
        }
        return reqTask
    }

    @discardableResult
    func run_backend(_ q_job: QuantumJob, _ response: @escaping ((_:Result) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
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
            var isTimeout = false
            let r = self.backendUtils.get_backend_instance(backend_name) { (backend,error) in
                if error != nil {
                    response(Result("0",error!,q_job.qobj))
                    return
                }
                let r = backend!.run(q_job) { (r) in
                    var result = r
                    if let error = result.get_error() {
                        if isTimeout {
                            switch error {
                            case QISKitError.jobTimeout(_):
                                break
                            default:
                                result._result["result"] = QISKitError.jobTimeout(timeout: q_job.timeout)
                            }
                        }
                    }
                    response(result)
                }
                reqTask.add(r)
            }
            reqTask.add(r)
            // cancel in case of timeout
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(q_job.timeout)) {
                isTimeout = true
                reqTask.cancel()
            }
        } catch {
            DispatchQueue.main.async {
                response(Result("0",error,q_job.qobj))
            }
        }
        return reqTask
    }
}
