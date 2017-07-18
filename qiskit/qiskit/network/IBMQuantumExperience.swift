//
//  IBMQuantumExperience.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 The Connector Class to do request to QX Platform
 */
public final class IBMQuantumExperience {

    private static let __names_backend_ibmqxv2 = Set<String>(["ibmqx5qv2", "ibmqx2", "qx5qv2", "qx5q", "real"])
    private static let __names_backend_ibmqxv3 = Set<String>(["ibmqx3"])
    private static let __names_backend_simulator = Set<String>(["simulator", "sim_trivial_2", "ibmqx_qasm_simulator"])

    let req: Request

    /**
     Creates Quantum Experience object with a given configuration.
     
     - parameter token: API token
     - parameter config: Qconfig object
     */
    public init(_ token: String, _ config: Qconfig? = nil, verify: Bool = true) throws {
        self.req = try Request(token,config,verify)
    }

    init() throws {
        self.req = try Request()
    }

    /**
     Check if the name of a backend is valid to run in QX Platform
     */
    private func _check_backend(_ back: String,
                                _ endpoint: String,
                                _ responseHandler: @escaping ((_:String?, _:IBMQuantumExperienceError?) -> Void)) {
        // First check against hacks for old backend names
        let original_backend = back
        let backend = back.lowercased()
         var ret: String? = nil
        if endpoint == "experiment" {
            if IBMQuantumExperience.__names_backend_ibmqxv2.contains(backend) {
                ret = "real"
            }
            else if IBMQuantumExperience.__names_backend_ibmqxv3.contains(backend) {
                ret = "ibmqx3"
            }
            else if IBMQuantumExperience.__names_backend_simulator.contains(backend) {
                ret = "sim_trivial_2"
            }
        }
        else if endpoint == "job" {
            if IBMQuantumExperience.__names_backend_ibmqxv2.contains(backend) {
                ret = "ibmqx2"
            }
            else if IBMQuantumExperience.__names_backend_ibmqxv3.contains(backend) {
                ret = "ibmqx3"
            }
            else if IBMQuantumExperience.__names_backend_simulator.contains(backend) {
                ret = "simulator"
            }
        }
        else if endpoint == "status" {
            if IBMQuantumExperience.__names_backend_ibmqxv2.contains(backend) {
                ret = "chip_real"
            }
            else if IBMQuantumExperience.__names_backend_ibmqxv3.contains(backend) {
                ret = "ibmqx3"
            }
            else if IBMQuantumExperience.__names_backend_simulator.contains(backend) {
                ret = "chip_simulator"
            }
        }
        else if endpoint == "calibration" {
            if IBMQuantumExperience.__names_backend_ibmqxv2.contains(backend) {
                ret = "ibmqx2"
            }
            else if IBMQuantumExperience.__names_backend_ibmqxv3.contains(backend) {
                ret = "ibmqx3"
            }
        }
        if ret != nil {
            responseHandler(ret,nil)
            return
        }
        // Check for new-style backends
        self.available_backends() { (backends,error) -> Void in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            for backend in backends {
                guard let name = backend["name"] as? String else {
                    continue
                }
                if name != original_backend {
                    continue
                }
                if let simulator = backend["simulator"] as? Bool {
                    if simulator {
                        responseHandler("chip_simulator",nil)
                        return
                    }
                }
                responseHandler(original_backend,nil)
                return
            }
            // backend unrecognized
            responseHandler(nil,nil)
        }
    }

    private func checkCredentials(request: Request, responseHandler: @escaping ((_:IBMQuantumExperienceError?) -> Void)) {
        if self.req.credential.token == nil {
            self.req.credential.obtainToken(request: request) { (error) -> Void in
                responseHandler(error)
            }
            return
        }
        responseHandler(nil)
    }

    /**
     Check if the user has permission in QX platform
     */
    private func _check_credentials() -> Bool {
        return self.req.credential.token != nil
    }

    /**
     Gets execution information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func get_execution(_ idExecution: String,
                             responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Executions/\(idExecution)") { (out, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                guard var execution = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                guard let codeId = execution["codeId"] as? String else {
                    responseHandler(execution, error)
                    return
                }
                self.get_code(codeId) { (code, error) -> Void in
                    if error != nil {
                        responseHandler(nil, error)
                        return
                    }
                    execution["code"] = code
                    responseHandler(execution, error)
                }
            }
        }
    }

    /**
     Gets execution result information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func get_result_from_execution(_ idExecution: String,
                                          responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Executions/\(idExecution)") { (out, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                guard let execution = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                var result: [String:Any] = [:]
                if let executionResult = execution["result"] as? [String:Any] {
                    if let data =  executionResult["data"] as? [String:Any] {
                        if let p = data["p"] {
                            result["measure"] = p
                        }
                        if let valsxyz = data["valsxyz"] {
                            result["bloch"] = valsxyz
                        }
                        if let additionalData = data["additionalData"] {
                            result["extraInfo"] = additionalData
                        }
                    }
                }
                if let calibration = execution["calibration"] as? [String:Any] {
                    result["calibration"] = calibration
                }
                responseHandler(result, error)
            }
        }
    }

    /**
     Gets code information. Asynchronous.

     - parameter idCode: code identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func get_code(_ idCode: String, responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Codes/\(idCode)") { (out, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                guard var code = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                self.req.get(path:"Codes/\(idCode)/executions",
                params:"filter={\"limit\":3}") { (executions, error) -> Void in
                    if error != nil {
                        responseHandler(nil, error)
                        return
                    }
                    code["executions"] = executions
                    responseHandler(code, error)
                }
            }
        }
    }

    /**
     Gets image. Asynchronous.

     - parameter idCode: Code Identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func get_image_code(_ idCode: String,
                             responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Codes/\(idCode)/export/png/url") { (out, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                guard let image = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                responseHandler(image, error)
            }
        }
    }

    /**
     Get the last codes of the user
     */
    public func get_last_codes(responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "users/\(self.req.credential.userId!)/codes/latest",
                         params: "&includeExecutions=true") { (out, error) -> Void in
                            if error != nil {
                                responseHandler(nil, error)
                                return
                            }
                            guard let result = out as? [String:Any] else {
                                responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                                return
                            }
                            responseHandler(result["codes"] as? [String:Any], error)
            }
        }
    }

    /**
     Runs an experiment. Asynchronous.
     */
    public func run_experiment(qasm: String,
                               backend: String = "simulator",
                               shots: Int = 1,
                               name: String? = nil,
                               seed: Double? = nil,
                               timeout: Int = 60,
                               responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self._check_backend(backend, "experiment") { (backend_type,error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if backend_type == nil {
                    responseHandler(nil,IBMQuantumExperienceError.missingBackend(backend: backend))
                    return
                }
                if !IBMQuantumExperience.__names_backend_simulator.contains(backend) && seed != nil {
                    responseHandler(nil,IBMQuantumExperienceError.errorSeed(backend: backend))
                    return
                }
                var data: [String : Any] = [:]
                if let n = name {
                    data["name"] = n
                } else {
                    let date = Date()
                    let calendar = Calendar.current
                    let c = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    data["name"] = "Experiment #\(c.year!)\(c.month!)\(c.day!)\(c.hour!)\(c.minute!)\(c.second!))"

                }
                data["qasm"] = qasm.replacingOccurrences(of: "IBMQASM 2.0;", with: "").replacingOccurrences(of: "OPENQASM 2.0;", with: "")
                data["codeType"] = "QASM2"

                if seed != nil {
                    if String(seed!).characters.count >= 11 {
                        responseHandler(nil,IBMQuantumExperienceError.errorSeedLength)
                        return
                    }
                    self.req.post(path: "codes/execute",
                                  params: "&shots=\(shots)&seed=\(seed!)&deviceRunType=\(backend_type!)",
                    data: data) { (out, error) -> Void in
                        guard let execution = out as? [String:Any] else {
                            responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                            return
                        }
                        self.post_run_experiment(execution,error,timeout,responseHandler)
                    }
                }
                else {
                    self.req.post(path: "codes/execute",
                                  params: "&shots=\(shots)&deviceRunType=\(backend_type!)",
                    data: data) { (out, error) -> Void in
                        guard let execution = out as? [String:Any] else {
                            responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                            return
                        }
                        self.post_run_experiment(execution,error,timeout,responseHandler)
                    }
                }
            }
        }
    }

    private func post_run_experiment(_ execution: [String:Any],
                                     _ error:IBMQuantumExperienceError?,
                                     _ timeout: Int,
                                     _ responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        if error != nil {
            responseHandler(nil, error)
            return
        }
        var respond: [String:Any] = [:]
        guard let statusMap = execution["status"] as? [String:Any] else {
            responseHandler(nil, IBMQuantumExperienceError.missingStatus)
            return
        }
        guard let status = statusMap["id"] as? String else {
            responseHandler(nil, IBMQuantumExperienceError.missingStatus)
            return
        }
        //print("Status: \(status)")
        guard let id_execution = execution["id"] as? String else {
            responseHandler(nil, IBMQuantumExperienceError.missingExecutionId)
            return
        }
        var result: [String:Any] = [:]
        respond["status"] = status
        respond["idExecution"] = id_execution
        respond["idCode"] = execution["codeId"]
        if let infoQueue = execution["infoQueue"] as? [String:Any] {
            respond["infoQueue"] = infoQueue
        }

        if status == "DONE" {
            if let executionResult = execution["result"] as? [String:Any] {
                if let data =  executionResult["data"] as? [String:Any] {
                    if let additionalData = data["additionalData"] {
                        result["extraInfo"] = additionalData
                    }
                    if let p = data["p"] {
                        result["measure"] = p
                    }
                    if let valsxyz = data["valsxyz"] {
                        result["bloch"] = valsxyz
                    }
                    respond["result"] = result
                    respond.removeValue(forKey: "infoQueue")
                }
            }
            responseHandler(respond, nil)
            return
        }
        if status == "ERROR" {
            respond.removeValue(forKey: "infoQueue")
            responseHandler(respond, nil)
            return
        }
        //print("Waiting for results...")
        self.getCompleteResultFromExecution(id_execution, ((timeout > 300) ? 300 : timeout)) { (out, error) in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            if let result = out {
                respond["status"] = "DONE"
                respond["result"] = result
                if let calibration = result["calibration"] {
                    respond["calibration"] = calibration
                }
                respond.removeValue(forKey: "infoQueue")
            }
            responseHandler(respond, error)
        }
    }

    private func getCompleteResultFromExecution(_ idExecution: String, _ timeOut: Int,
                                                responseHandler:
        @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.get_result_from_execution(idExecution) { (execution, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if timeOut <= 0 {
                    responseHandler(execution, error)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getCompleteResultFromExecution(idExecution, timeOut-1, responseHandler: responseHandler)
                }
            }
        }
    }

    /**
     Runs a job. Asynchronous.
     */
    public func run_job(qasms: [[String:Any]],
                        backend: String = "simulator",
                        shots: Int = 1,
                        maxCredits: Int = 3,
                        seed: Double? = nil,
                        responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {

        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }

            var data: [String : Any] = [:]
            var qasmArray: [[String:Any]] = []
            for var dict in qasms {
                if var value = dict["qasm"] as? String {
                    value = value.replacingOccurrences(of: "IBMQASM 2.0;", with: "")
                    dict["qasm"] = value.replacingOccurrences(of: "OPENQASM 2.0;", with: "") 
                }
                qasmArray.append(dict)
            }
            data["qasms"] = qasmArray 
            data["shots"] = shots 
            data["maxCredits"] = maxCredits

            self._check_backend(backend, "job") { (backend_type,error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if backend_type == nil {
                    responseHandler(nil,IBMQuantumExperienceError.missingBackend(backend: backend))
                    return
                }
                if !IBMQuantumExperience.__names_backend_simulator.contains(backend) && seed != nil {
                    responseHandler(nil,IBMQuantumExperienceError.errorSeed(backend: backend))
                    return
                }
                if seed != nil {
                    if String(seed!).characters.count >= 11 {
                        responseHandler(nil,IBMQuantumExperienceError.errorSeedLength)
                        return
                    }
                    data["seed"] = seed!
                }
                var backendDict: [String:String] = [:]
                backendDict["name"] = backend_type!
                data["backend"] = backendDict

                self.req.post(path: "Jobs", data: data) { (out, error) -> Void in
                    if error != nil {
                        responseHandler(nil, error)
                        return
                    }
                    guard let json = out as? [String:Any] else {
                        responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                        return
                    }
                    responseHandler(json, error)
                }

            }

        }
    }

    /**
     Gets job information. Asynchronous.

     - parameter jobId: job identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func get_job(jobId: String, responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Jobs/\(jobId)") { (out, error) -> Void in
                guard let json = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                responseHandler(json, error)
            }
        }
    }

    /**
     Gets jobs information. Asynchronous.
     -limit: max result
     - parameter responseHandler: Closure to be called upon completion
     */
    public func get_jobs(limit: Int = 50,responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Jobs", params: "&filter={\"limit\":\(limit)}") { (out, error) -> Void in
                guard let json = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                responseHandler(json, error)
            }
        }
    }

    /**
     Get the status of a chip
     */
    public func backend_status(_ backend: String = "ibmqx2",
                       responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self._check_backend(backend, "status") { (backend_type,error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            if backend_type == nil {
                responseHandler(nil,IBMQuantumExperienceError.missingBackend(backend: backend))
                return
            }
            self.req.get(path:"Status/queue?backend=\(backend_type!)",with_token: false) { (out, error) -> Void in
                guard let json = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                responseHandler(["available" : (json["state"] != nil) ], error)
            }
        }
    }

    /**
     Get the calibration of a real chip
     */
    public func backend_calibration(_ backend: String = "ibmqx2",
                            responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self._check_backend(backend, "calibration") { (backend_type,error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if backend_type == nil {
                    responseHandler(nil,IBMQuantumExperienceError.missingBackend(backend: backend))
                    return
                }
                self.req.get(path:"Backends/\(backend_type!)/calibration") { (out, error) -> Void in
                    if error != nil {
                        responseHandler(nil, error)
                        return
                    }
                    guard var ret = out as? [String:Any] else {
                        responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                        return
                    }
                    ret["backend"] = backend_type!
                    responseHandler(ret,error)
                }
            }
        }
    }

    /**
     Get the parameters of calibration of a real chip
     */
    public func backend_parameters(_ backend: String = "ibmqx2",
                                  responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self._check_backend(backend, "calibration") { (backend_type,error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if backend_type == nil {
                    responseHandler(nil,IBMQuantumExperienceError.missingBackend(backend: backend))
                    return
                }
                self.req.get(path:"Backends/\(backend_type!)/parameters") { (out, error) -> Void in
                    if error != nil {
                        responseHandler(nil, error)
                        return
                    }
                    guard var ret = out as? [String:Any] else {
                        responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                        return
                    }
                    ret["backend"] = backend_type!
                    responseHandler(ret,error)
                }
            }
        }
    }

    /**
     Get the backends availables to use in the QX Platform
     */
    public func available_backends(responseHandler: @escaping ((_:[[String:Any]], _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler([], error)
                return
            }
            self.req.get(path: "Backends") { (out, error) -> Void in
                if error != nil {
                    responseHandler([], error)
                    return
                }
                guard let backends = out as? [[String:Any]] else {
                    responseHandler([],IBMQuantumExperienceError.missingBackends)
                    return
                }
                var ret: [[String:Any]] = []
                for backend in backends {
                    if let status = backend["status"] as? String {
                        if "on" == status {
                            ret.append(backend)
                        }
                    }
                }
                responseHandler(ret, nil)
            }
        }
    }

    /**
     Get the backend simulators available to use in the QX Platform
     */
    public func available_backend_simulators(responseHandler: @escaping ((_:[[String:Any]], _:IBMQuantumExperienceError?) -> Void)) {
        self.available_backends() { (backends,error) -> Void in
            if error != nil {
                responseHandler([], error)
                return
            }
            var ret: [[String:Any]] = []
            for backend in backends {
                if let simulator = backend["simulator"] as? Bool {
                    if simulator {
                        ret.append(backend)
                    }
                }
            }
            responseHandler(ret, nil)
        }
    }
}
