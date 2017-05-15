//
//  IBMQuantumExperience.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum Experience Exceptions
 */
public enum IBMQuantumExperienceError: Error, CustomStringConvertible {

    case invalidURL(url: String)
    case nullResponse(url: String)
    case invalidHTTPResponse(response: URLResponse)
    case httpError(url: String, status: Int, msg: String)
    case nullResponseData(url: String)
    case missingTokenId
    case missingJobId
    case missingExecutionId
    case missingStatus
    case timeout
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .invalidURL(let url):
            return url
        case .nullResponse(let url):
            return url
        case .invalidHTTPResponse(let response):
            return response.description
        case .httpError(let url, let status, let msg):
            return "\(url) Http status: \(status); \(msg)"
        case .nullResponseData(let url):
            return url
        case .missingTokenId():
            return "Missing TokenId"
        case .missingJobId():
            return "Missing JobId"
        case .missingExecutionId():
            return "Missing ExecutionId"
        case .missingStatus():
            return "Missing Status"
        case .timeout():
            return "Timeout"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}

/**
 Quantum Experience REST Access API
 */
public final class IBMQuantumExperience {

    private let credentials: Credentials
    private let request: Request

    /**
     Creates Quantum Experience object with a given configuration.
     
     - parameter config: Qconfig object
     */
    public init(config: Qconfig) {
        self.credentials = Credentials(config: config)
        self.request = Request(self.credentials)
    }

    private func checkCredentials(request: Request, responseHandler: @escaping ((_:Error?) -> Void)) {
        if self.credentials.token == nil {
            self.credentials.obtainToken(request: request) { (error) -> Void in
                responseHandler(error)
            }
            return
        }
        responseHandler(nil)
    }

    /**
     Runs a job. Asynchronous.

     - parameter qasms: Array of qasm code string
     - parameter backend: Backend type
     - parameter shots:
     - parameter maxCredits:
     - parameter responseHandler: Closure to be called upon completion
     */
    public func runJob(qasms: [String], backend: String, shots: Int, maxCredits: Int,
                       responseHandler: @escaping ((_:RunJobResult?, _:Error?) -> Void)) {

        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            var data: [String : AnyObject] = [:]
            var qasmArray: [[String:String]] = []
            for qasm in qasms {
                var q: [String: String] = [:]
                q["qasm"] = qasm.replacingOccurrences(of: "IBMQASM 2.0;", with: "")
                q["qasm"] = qasm.replacingOccurrences(of: "OPENQASM 2.0;", with: "")
                qasmArray.append(q)
            }
            data["qasms"] = qasmArray as AnyObject
            data["shots"] = shots as AnyObject
            data["maxCredits"] = maxCredits as AnyObject
            var backendDict: [String:String] = [:]
            backendDict["name"] = backend
            data["backend"] = backendDict as AnyObject
            self.request.post(path: "Jobs", data: data) { (json, error) -> Void in
                DispatchQueue.main.async {
                    responseHandler(RunJobResult(json), error)
                }
            }
        }
    }

    /**
     Gets job information. Asynchronous.

     - parameter jobId: job identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getJob(jobId: String, responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.request.get(path: "Jobs/\(jobId)") { (json, error) -> Void in
                DispatchQueue.main.async {
                    responseHandler(GetJobResult(json), error)
                }
            }
        }
    }

    /**
     Runs a job and gets its information once its status changes from RUNNING. Asynchronous.

     - parameter qasms: Array of qasm code string
     - parameter Backend: Backend type
     - parameter shots:
     - parameter maxCredits:
     - parameter wait: wait in seconds
     - parameter timeout: timeout in seconds
     - parameter responseHandler: Closure to be called upon completion
     */
    public func runJobToCompletion(qasms: [String], backend: String, shots: Int, maxCredits: Int,
                                   wait: Int = 5, timeout: Int = 60,
                                   responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
        self.runJob(qasms: qasms, backend: backend, shots: shots, maxCredits: maxCredits) { (out, error) in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            guard let runJobResult = out else {
                responseHandler(nil, IBMQuantumExperienceError.missingStatus)
                return
            }
            guard let status = runJobResult.status else {
                responseHandler(nil, IBMQuantumExperienceError.missingStatus)
                return
            }
            print("Status: \(status)")
            guard let jobid = runJobResult.jobId else {
                responseHandler(nil, IBMQuantumExperienceError.missingJobId)
                return
            }
            print("JobId: \(jobid)")

            self.waitForJob(jobid, wait, timeout) { (result, error) in
                responseHandler(result, error)
            }
        }
    }

    /**
     Gets job information once its status changes from RUNNING. Asynchronous.

     - parameter jobId: job identifier
     - parameter wait: wait in seconds
     - parameter timeout: timeout in seconds
     - parameter responseHandler: Closure to be called upon completion
     */
    public func waitForJob(_ jobId: String, _ wait: Int, _ timeout: Int,
                           _ responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
        self.waitForJob(jobId, wait, timeout, 0, responseHandler)
    }

    private func waitForJob(_ jobId: String, _ wait: Int, _ timeout: Int, _ elapsed: Int,
                            _ responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
        self.getJob(jobId: jobId) { (result, error) -> Void in
            if error != nil {
                responseHandler(result, error)
                return
            }
            guard let jobResult = result else {
                responseHandler(result, IBMQuantumExperienceError.missingStatus)
                return
            }
            guard let status = jobResult.status else {
                responseHandler(result, IBMQuantumExperienceError.missingStatus)
                return
            }
            if status != "RUNNING" {
                responseHandler(result, nil)
                return
            }
            if elapsed >= timeout {
                responseHandler(result, IBMQuantumExperienceError.timeout)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(wait)) {
                self.waitForJob(jobId, wait, timeout, elapsed + wait, responseHandler)
            }
        }
    }

    /**
     Gets execution information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getExecution(_ idExecution: String,
                             responseHandler: @escaping ((_:GetExecutionResult?, _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.request.get(path: "Executions/\(idExecution)") { (out, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(nil, error)
                    }
                    return
                }
                let execution = GetExecutionResult(out)
                guard let codeId = execution.codeId else {
                    DispatchQueue.main.async {
                        responseHandler(execution, error)
                    }
                    return
                }
                self.getCode(codeId) { (code, error) -> Void in
                    if error != nil {
                        DispatchQueue.main.async {
                            responseHandler(nil, error)
                        }
                        return
                    }
                    let execution = GetExecutionResult(out, code)
                    DispatchQueue.main.async {
                        DispatchQueue.main.async {
                            responseHandler(execution, error)
                        }
                    }
                }
            }
        }
    }

    /**
     Gets execution result information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getResultFromExecution(_ idExecution: String,
                                       responseHandler: @escaping ((_:GetExecutionResult.Result?, _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.request.get(path: "Executions/\(idExecution)") { (out, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(nil, error)
                    }
                    return
                }
                let execution = GetExecutionResult(out)
                DispatchQueue.main.async {
                    responseHandler(execution.result, error)
                }
            }
        }
    }

    /**
     Gets code information. Asynchronous.

     - parameter idCode: code identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    private func getCode(_ idCode: String, responseHandler: @escaping ((_:[String:AnyObject], _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler([:], error)
                }
                return
            }
            self.request.get(path: "Codes/\(idCode)") { (code, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(code, error)
                    }
                    return
                }
                self.request.get(path:"Codes/\(idCode)/executions",
                                 params:"filter={\"limit\":3}") { (executions, error) -> Void in
                    if error != nil {
                        DispatchQueue.main.async {
                            responseHandler(code, error)
                        }
                        return
                    }
                    var codeCopy = code
                    codeCopy["executions"] = executions as AnyObject
                    DispatchQueue.main.async {
                        responseHandler(codeCopy, error)
                    }
                }
            }
        }
    }

    /**
     Runs an experiment. Asynchronous.

     - parameter qasms: Array of qasm code string
     - parameter backend: Backend type
     - parameter shots:
     - parameter name: Experiment name
     - parameter timeout:
     - parameter responseHandler: Closure to be called upon completion
     */
    public func runExperiment(qasm: String, backend: String, shots: Int, name: String? = nil, timeout: Int = 60,
                              responseHandler: @escaping ((_:RunExperimentResult?, _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            var data: [String : AnyObject] = [:]
            var q: String = qasm.replacingOccurrences(of: "IBMQASM 2.0;", with: "")
            q = q.replacingOccurrences(of: "OPENQASM 2.0;", with: "")
            data["qasm"] = q as AnyObject
            data["codeType"] = "QASM2" as AnyObject
            if let n = name {
                 data["name"] = n as AnyObject
            } else {
                let date = Date()
                let calendar = Calendar.current
                let c = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                data["name"] = "Experiment #\(c.year!)\(c.month!)\(c.day!)\(c.hour!)\(c.minute!)\(c.second!))"
                    as AnyObject
            }
            self.request.post(path: "codes/execute", params: "&shots=\(shots)&deviceRunType=\(backend)",
                              data: data) { (json, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(nil, error)
                    }
                    return
                }
                let runExperimentResult = RunExperimentResult(json)
                guard let status = runExperimentResult.status else {
                    DispatchQueue.main.async {
                        responseHandler(nil, IBMQuantumExperienceError.missingStatus)
                    }
                    return
                }
                print("Status: \(status)")
                if status == "DONE" {
                    DispatchQueue.main.async {
                        responseHandler(runExperimentResult, nil)
                    }
                    return
                }
                if status == "ERROR" {
                    DispatchQueue.main.async {
                        responseHandler(runExperimentResult, nil)
                    }
                    return
                }
                guard let executionId = runExperimentResult.executionId else {
                    DispatchQueue.main.async {
                        responseHandler(nil, IBMQuantumExperienceError.missingExecutionId)
                    }
                    return
                }
                self.getCompleteResultFromExecution(executionId, ((timeout > 300) ? 300 : timeout)) { (out, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            responseHandler(nil, error)
                        }
                        return
                    }
                    guard let result = out else {
                        DispatchQueue.main.async {
                            responseHandler(nil, IBMQuantumExperienceError.missingStatus)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        responseHandler(RunExperimentResult(result.json), error)
                    }
                }
            }
        }
    }

    private func getCompleteResultFromExecution(_ idExecution: String, _ timeOut: Int,
                                                responseHandler:
                                                @escaping ((_:GetExecutionResult.Result?, _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.getResultFromExecution(idExecution) { (execution, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(nil, error)
                    }
                    return
                }
                if timeOut <= 0 {
                    DispatchQueue.main.async {
                        responseHandler(execution, error)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getCompleteResultFromExecution(idExecution, timeOut-1, responseHandler: responseHandler)
                }
            }
        }
    }

    /**
     Gets image. Asynchronous.

     - parameter idCode: Code Identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getImageCode(_ idCode: String,
                             responseHandler: @escaping ((_:[String:AnyObject]?, _:Error?) -> Void)) {
        self.checkCredentials(request: self.request) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.request.get(path: "Codes/\(idCode)/export/png/url") { (image, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(image, error)
                    }
                    return
                }
                DispatchQueue.main.async {
                    responseHandler(image, error)
                }
            }
        }
    }

}
