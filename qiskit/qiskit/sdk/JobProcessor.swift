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

    /**
     Run a program of compiled quantum circuits on the local machine.
     Args:
         qobj (dict): quantum object dictionary
     Returns:
         Dictionary of form,
         job_result = {
         "status": DATA,
         "result" : [
         {
         "data": DATA,
         "status": DATA,
         },
         ...
         ]
         "name": DATA,
         "backend": DATA
         }
     */
    private static func run_local_backend(_ q: [String:Any]) throws -> Result {
        var qobj = q
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
        if let config = qobj["config"] as? [String:Any] {
            if let backend = config["backend"] as? String {
                let backendClass = try BackendUtils.get_backend_class(backend)
                let backend = backendClass.init(qobj)
                return try backend.run()
            }
        }
        throw QISKitError.missingCompiledConfig
    }

    private static func run_remote_backend(_ q: [String: Any],
                                   _ api: IBMQuantumExperience,
                                   _ wait: Int = 5,
                                   _ timeout: Int = 60,
                                   _ silent: Bool = true,
                    _ responseHandler: @escaping ((_:Result,_:QISKitError?) -> Void)) {
        do {
            var qobj = q
            var api_jobs: [[String:Any]] = []
            var seed0: Int? = nil
            if let circuits = qobj["circuits"] as? [[String:Any]] {
                var newCircuits: [[String:Any]] = []
                for (index,c) in circuits.enumerated() {
                    var circuit = c
                    var isNull = circuit["compiled_circuit"] == nil
                    if !isNull {
                        if let _ = circuit["compiled_circuit"] as? NSNull {
                            isNull = true
                        }
                    }
                    if isNull {
                        if let dagCircuit = circuit["circuit"] as? DAGCircuit {
                            let compiled_circuit = try OpenQuantumCompiler.compile(dagCircuit.qasm())
                            circuit["compiled_circuit_qasm"] = try compiled_circuit.dag!.qasm(qeflag: true)
                        }
                    }
                    newCircuits.append(circuit)
                    if let bytes = circuit["compiled_circuit_qasm"] as? [UInt8] {
                        api_jobs.append(["qasm": String(bytes: bytes, encoding: .utf8)!])
                    }
                    else {
                        api_jobs.append(["qasm": circuit["compiled_circuit_qasm"] as! String])
                    }
                    if index == 0 {
                        if let config = circuit["config"] as? [String:Any] {
                            if let seed = config["seed"] as? Int {
                                seed0 = seed
                            }
                        }
                    }
                }
                qobj["circuits"] = newCircuits
            }
            var backend: String = ""
            var shots: Int = 0
            var max_credits: Int = 0
            if let config = qobj["config"] as? [String:Any] {
                if let b = config["backend"] as? String {
                    backend = b
                }
                if let s = config["shots"] as? Int {
                    shots = s
                }
                if let m = config["max_credits"] as? Int {
                    max_credits = m
                }
            }
            api.run_job(qasms: api_jobs, backend: backend, shots: shots, maxCredits: max_credits, seed: seed0) { (json, error) -> Void in
                if error != nil {
                    responseHandler(Result(),QISKitError.internalError(error: error!))
                    return
                }
                guard let output = json else {
                    responseHandler(Result(),QISKitError.missingJobId)
                    return
                }
                if let error = output["error"] as? [String:Any] {
                    responseHandler(Result(),QISKitError.errorResult(result: ResultError(error)))
                    return
                }
                guard let jobId = output["id"] as? String else {
                    responseHandler(Result(),QISKitError.missingJobId)
                    return
                }
                wait_for_job(jobId, api, wait: wait, timeout: timeout, silent: silent) { (json, error) -> Void in
                    if error != nil {
                        responseHandler(Result(),QISKitError.internalError(error: error!))
                        return
                    }
                    var job_result = json!
                    if let id = qobj["id"] {
                        job_result["name"] = id
                    }
                    job_result["backend"] = backend
                    responseHandler(Result(job_result, qobj),nil)
                }
            }
        } catch {
            if let err = error as? QISKitError {
                responseHandler(Result(),err)
                return
            }
            responseHandler(Result(),QISKitError.internalError(error: error))
            return
        }
    }

    private static func wait_for_job(_ jobId: String, _ api: IBMQuantumExperience, wait: Int = 5, timeout: Int = 60, silent: Bool = true,
                             _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitError?) -> Void)) {
        wait_for_job(api, jobId, wait, timeout, silent, 0, responseHandler)
    }

    private static func wait_for_job(_ api: IBMQuantumExperience, _ jobid: String, _ wait: Int, _ timeout: Int, _ silent: Bool, _ elapsed: Int,
                              _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitError?) -> Void)) {
        api.get_job(jobId: jobid) { (result, error) -> Void in
            if error != nil {
                responseHandler(nil, QISKitError.internalError(error: error!))
                return
            }
            guard let jobResult = result else {
                responseHandler(nil, QISKitError.missingStatus)
                return
            }
            guard let status = jobResult["status"] as? String else {
                responseHandler(nil, QISKitError.missingStatus)
                return
            }
            if !silent {
                print("status = \(status) (\(elapsed) seconds)")
            }
            if status != "RUNNING" {
                if status == "ERROR_CREATING_JOB" || status == "ERROR_RUNNING_JOB" {
                    responseHandler(nil, QISKitError.errorStatus(status: status))
                    return
                }
                // Get the results
                var job_result_return: [[String:Any]] = []
                if let qasms = jobResult["qasms"] as? [[String:Any]] {
                    for qasm in qasms {
                        if let data = qasm["data"],
                            let status = qasm["status"] {
                            job_result_return.append(["data": data, "status": status])
                        }
                    }
                }
                responseHandler(["status": status, "result": job_result_return],nil)
                return
            }
            if elapsed >= timeout {
                responseHandler(nil, QISKitError.timeout)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(wait)) {
                wait_for_job(api,jobid, wait, timeout, silent, elapsed + wait, responseHandler)
            }
        }
    }

    /**
     Get the remote backends.
         Queries network API if it exists and gets the backends that are online.
     Returns:
         List of online backends if the online api has been set or an empty
         list of it has not been set.
     */
    private static func remote_backends(_ api: IBMQuantumExperience, responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        api.available_backends() { (backends,error) in
            if error != nil {
                responseHandler([],error)
                return
            }
            var ret: Set<String> = []
            for backend in backends {
                if let name = backend["name"] as? String {
                    ret.update(with: name)
                }
            }
            responseHandler(ret,nil)
        }
    }

    let identifier: String
    private let q_jobs: [QuantumJob]
    private let _local_backends: Set<String>
    private var online: Bool = false
    private let callback: ((_:String, _:[Result]) -> Void)?
    private var num_jobs: Int
    private var jobs_results: [Result] = []
    private var _api: IBMQuantumExperience? = nil

    /**
     Args:
     q_jobs (list(QuantumJob)): List of QuantumJob objects.
     callback (fn(results)): The function that will be called when all
     jobs finish. The signature of the function must be: fn(results) results: A list of Result objects.
     token (str): Server API token
     url (str): Server URL.
     api (IBMQuantumExperience): API instance to use. If set, /token/ and /url/ are ignored.
     */
    init(_ q_jobs: [QuantumJob],
         callback: ((_:String, _:[Result]) -> Void)?,
         token: String? = nil,
         url: String? = nil,
         api: IBMQuantumExperience? = nil) throws {
        self.identifier = UUID().uuidString
        self.q_jobs = q_jobs

        // check whether any jobs are remote
        self._local_backends = BackendUtils.local_backends()
        for qj in self.q_jobs {
            if !self._local_backends.contains(qj.backend) {
                self.online = true
                break
            }
        }
        self.callback = callback
        self.num_jobs = self.q_jobs.count
        if self.online {
            let qConfig = (url != nil) ? try Qconfig(url: url!) : try Qconfig()
            self._api = api != nil ? api! : try IBMQuantumExperience(token,qConfig)
        }
    }

    private func _job_done_callback(_ result: Result) {
        SyncLock.synchronized(self) {
            self.jobs_results.append(result)
            if self.num_jobs > 0 {
                self.num_jobs -= 1
            }
        }
        if self.num_jobs == 0 {
            self.callback?(self.identifier,self.jobs_results)
        }
    }

    /**
     AProcess/submit jobs

     Args:
     wait (int): Time interval to wait between requests for results
     timeout (int): Total time waiting for the results
     silent (bool): If true, prints out results
     */
    func submit(_ wait: Int = 5, _ timeout: Int = 120, _ silent: Bool = true) {
        for q_job in self.q_jobs {
            if self._local_backends.contains(q_job.backend) {
                DispatchQueue.global().async {
                    var result: Result? = nil
                    do {
                        result = try JobProcessor.run_local_backend(q_job.qobj)
                    }
                    catch {
                        result = Result(["status": "ERROR","result": error.localizedDescription],q_job.qobj)
                    }
                    DispatchQueue.main.async {
                        self._job_done_callback(result!)
                    }
                }
            }
            else if self.online {
                JobProcessor.remote_backends(self._api!) { (backends,error) in
                    if error != nil {
                        self._job_done_callback(Result(["status": "ERROR","result": error!.localizedDescription],q_job.qobj))
                        return
                    }
                    if !backends.contains(q_job.backend) {
                        self._job_done_callback(Result(["status": "ERROR","result": QISKitError.missingBackend(backend: q_job.backend).localizedDescription],q_job.qobj))
                        return
                    }
                    if backends.contains(q_job.backend) {
                        JobProcessor.run_remote_backend(q_job.qobj,self._api!,wait,timeout,silent) { (result,error) in
                            if error != nil {
                                self._job_done_callback(Result(["status": "ERROR","result": error!.localizedDescription],q_job.qobj))
                                return
                            }
                            self._job_done_callback(result)
                        }
                    }
                }
            }
            else {
                self._job_done_callback(Result(["status": "ERROR","result": QISKitError.missingBackend(backend: q_job.backend).localizedDescription],q_job.qobj))
            }
        }
    }
}
