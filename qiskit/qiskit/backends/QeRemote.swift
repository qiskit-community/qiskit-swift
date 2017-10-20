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
 Backend class interfacing with the Quantum Experience remotely.

 Attributes:
 _api (IBMQuantumExperience): api for communicating with the Quantum Experience.
 */
final class QeRemote: BaseBackend {

    var api: IBMQuantumExperience? = nil

    public required init(_ configuration: [String:Any]?) {
        super.init(configuration)
        if var conf = configuration {
            conf["local"] = false
            self._configuration = conf
        }
    }

    /**
     Run jobs

     Args:
         q_job (QuantumJob): job to run

     Returns:
         Result object.
     */
    override public func run(_ q_job: QuantumJob, response: @escaping ((_:Result) -> Void)) {
        self.runInternal(q_job) {  (result) -> Void in
            DispatchQueue.main.async {
                response(result)
            }
        }
    }
    
    private func runInternal(_ q_job: QuantumJob, response: @escaping ((_:Result) -> Void)) {
        do {
            var qobj = q_job.qobj
            let wait = q_job.wait
            let timeout = q_job.timeout
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
            self.api!.run_job(qasms: api_jobs, backend: backend, shots: shots, maxCredits: max_credits, seed: seed0) { (output, error) -> Void in
                if error != nil {
                    response(Result(["job_id": "0","status": "ERROR","result": QISKitError.internalError(error: error!).localizedDescription],q_job.qobj))
                    return
                }
                if let error = output["error"] as? [String:Any] {
                    response(Result(["job_id": "0","status": "ERROR","result": QISKitError.errorResult(result: ResultError(error)).localizedDescription],q_job.qobj))
                    return
                }
                guard let jobId = output["id"] as? String else {
                    response(Result(["job_id": "0","status": "ERROR","result": QISKitError.missingJobId.localizedDescription],q_job.qobj))
                    return
                }
                QeRemote.wait_for_job(jobId, self.api!, wait: wait, timeout: timeout) { (json, error) -> Void in
                    if error != nil {
                        response(Result(["job_id": jobId, "status": "ERROR","result": QISKitError.internalError(error: error!).localizedDescription],q_job.qobj))
                        return
                    }
                    var job_result = json
                    if let id = qobj["id"] {
                        job_result["name"] = id
                    }
                    job_result["backend"] = backend
                    response(Result(job_result, qobj))
                }
            }
        } catch {
            if let err = error as? QISKitError {
                response(Result(["job_id": "0","status": "ERROR","result": err.localizedDescription],q_job.qobj))
                return
            }
            response(Result(["job_id": "0","status": "ERROR","result": QISKitError.internalError(error: error).localizedDescription],q_job.qobj))
            return
        }
    }

    private static func run_remote_backend(_ q: [String: Any],
                                           _ api: IBMQuantumExperience,
                                           _ wait: Int = 5,
                                           _ timeout: Int = 60,
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
            api.run_job(qasms: api_jobs, backend: backend, shots: shots, maxCredits: max_credits, seed: seed0) { (output, error) -> Void in
                if error != nil {
                    responseHandler(Result(),QISKitError.internalError(error: error!))
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
                wait_for_job(jobId, api, wait: wait, timeout: timeout) { (json, error) -> Void in
                    if error != nil {
                        responseHandler(Result(),QISKitError.internalError(error: error!))
                        return
                    }
                    var job_result = json
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

    private static func wait_for_job(_ jobId: String, _ api: IBMQuantumExperience, wait: Int = 5, timeout: Int = 60,
                                     _ responseHandler: @escaping ((_:[String:Any], _:QISKitError?) -> Void)) {
        wait_for_job(api, jobId, wait, timeout, 0, responseHandler)
    }

    private static func wait_for_job(_ api: IBMQuantumExperience, _ jobid: String, _ wait: Int, _ timeout: Int, _ elapsed: Int,
                                     _ responseHandler: @escaping ((_:[String:Any], _:QISKitError?) -> Void)) {
        api.get_job(jobId: jobid) { (jobResult, error) -> Void in
            if error != nil {
                responseHandler([:], QISKitError.internalError(error: error!))
                return
            }
            guard let status = jobResult["status"] as? String else {
                responseHandler([:], QISKitError.missingStatus)
                return
            }
            if status != "RUNNING" {
                if status == "ERROR_CREATING_JOB" || status == "ERROR_RUNNING_JOB" {
                    responseHandler([:], QISKitError.errorStatus(status: status))
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
                responseHandler([:], QISKitError.timeout)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(wait)) {
                SDKLogger.logInfo("status = %@ (%d seconds)",status,elapsed + wait)
                wait_for_job(api,jobid, wait, timeout, elapsed + wait, responseHandler)
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
}
