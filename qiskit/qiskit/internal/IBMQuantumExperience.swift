//
//  IBMQuantumExperience.swift
//  qiskit
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
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}

/**
 Quantum Experience runJob result model
 */
public final class RunJobResult: CustomStringConvertible {

    public let json: [String: AnyObject]
    public private(set) var qasms: [QASMRun]?
    public private(set) var shots: Int?
    public private(set) var backend: Backend?
    public private(set) var status: String?
    public private(set) var maxCredits: Int?
    public private(set) var usedCredits: Int?
    public private(set) var creationDate: String?
    public private(set) var deleted: Bool?
    public private(set) var jobId: String?
    public private(set) var userId: String?
    public var description: String {
        return self.json.description
    }

    public final class QASMRun: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var qasm: String?
        public private(set) var status: String?
        public private(set) var executionId: String?
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let qasm = json["qasm"] as? String {
                self.qasm = qasm
            }
            if let status = json["status"] as? String {
                self.status = status
            }
            if let executionId = json["executionId"] as? String {
                self.executionId = executionId
            }
        }
    }

    public final class Backend: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var name: String?
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let name = json["name"] as? String {
                self.name = name
            }
        }
    }

    init(_ json: [String: AnyObject]) {
        self.json = json
        if let qasms = json["qasms"] as? [[String:AnyObject]] {
            for qasm in qasms {
                if self.qasms == nil {
                    self.qasms = []
                }
                self.qasms!.append(QASMRun(qasm))
            }
        }
        if let shots = json["shots"] as? NSNumber {
            self.shots = shots.intValue
        }
        if let backend = json["backend"] as? [String:AnyObject] {
            self.backend = Backend(backend)
        }
        if let status = json["status"] as? String {
            self.status = status
        }
        if let maxCredits = json["maxCredits"] as? NSNumber {
            self.maxCredits = maxCredits.intValue
        }
        if let usedCredits = json["usedCredits"] as? NSNumber {
            self.usedCredits = usedCredits.intValue
        }
        if let creationDate = json["creationDate"] as? String {
            self.creationDate = creationDate
        }
        if let deleted = json["deleted"] as? NSNumber {
            self.deleted = deleted.boolValue
        }
        if let jobId = json["id"] as? String {
            self.jobId = jobId
        }
        if let userId = json["userId"] as? String {
            self.userId = userId
        }
    }
}

/**
 Quantum Experience getJob result model
 */
public final class GetJobResult: CustomStringConvertible {

    public let json: [String: AnyObject]
    public private(set) var qasms: [QASMResult]?
    public private(set) var shots: Int?
    public private(set) var backend: Backend?
    public private(set) var status: String?
    public private(set) var maxCredits: Int?
    public private(set) var usedCredits: Int?
    public private(set) var creationDate: String?
    public private(set) var deleted: Bool?
    public private(set) var jobId: String?
    public private(set) var userId: String?
    public var description: String {
        return self.json.description
    }

    public final class QASMResult: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var qasm: String?
        public private(set) var status: String?
        public private(set) var executionId: String?
        public private(set) var result: Result?
        public var description: String {
            return self.json.description
        }

        public final class Result: CustomStringConvertible {

            public let json: [String: AnyObject]
            public private(set) var date: String?
            public private(set) var data: Data?
            public var description: String {
                return self.json.description
            }

            public final class Data: CustomStringConvertible {

                public let json: [String: AnyObject]
                public private(set) var time: Double?
                public private(set) var counts: [String:NSNumber]?
                public var description: String {
                    return self.json.description
                }

                init(_ json: [String: AnyObject]) {
                    self.json = json
                    if let time = json["time"] as? NSNumber {
                        self.time = time.doubleValue
                    }
                    if let counts = json["counts"] as? [String:NSNumber] {
                        self.counts = counts
                    }
                }
            }

            init(_ json: [String: AnyObject]) {
                self.json = json
                if let date = json["date"] as? String {
                    self.date = date
                }
                if let data = json["data"] as? [String:AnyObject] {
                self.data = Data(data)
                }
            }
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let qasm = json["qasm"] as? String {
                self.qasm = qasm
            }
            if let status = json["status"] as? String {
                self.status = status
            }
            if let executionId = json["executionId"] as? String {
                self.executionId = executionId
            }
            if let result = json["result"] as? [String:AnyObject] {
                self.result = Result(result)
            }
        }
    }

    public final class Backend: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var name: String?
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let name = json["name"] as? String {
                self.name = name
            }
        }
    }

    init(_ json: [String: AnyObject]) {
        self.json = json
        if let qasms = json["qasms"] as? [[String:AnyObject]] {
            for qasm in qasms {
                if self.qasms == nil {
                    self.qasms = []
                }
                self.qasms!.append(QASMResult(qasm))
            }
        }
        if let shots = json["shots"] as? NSNumber {
            self.shots = shots.intValue
        }
        if let backend = json["backend"] as? [String:AnyObject] {
            self.backend = Backend(backend)
        }
        if let status = json["status"] as? String {
            self.status = status
        }
        if let maxCredits = json["maxCredits"] as? NSNumber {
            self.maxCredits = maxCredits.intValue
        }
        if let usedCredits = json["usedCredits"] as? NSNumber {
            self.usedCredits = usedCredits.intValue
        }
        if let creationDate = json["creationDate"] as? String {
            self.creationDate = creationDate
        }
        if let deleted = json["deleted"] as? NSNumber {
            self.deleted = deleted.boolValue
        }
        if let jobId = json["id"] as? String {
            self.jobId = jobId
        }
        if let userId = json["userId"] as? String {
            self.userId = userId
        }
    }
}

/**
 Quantum Experience getExecution result model
 */
public final class GetExecutionResult: CustomStringConvertible {

    public let json: [String: AnyObject]
    public private(set) var result: Result?
    public private(set) var startDate: String?
    public private(set) var modificationDate: Int?
    public private(set) var time: Double?
    public private(set) var endDate: String?
    public private(set) var typeCredits: String?
    public private(set) var status: Status?
    public private(set) var resultIP: ResultIP?
    public private(set) var calibration: Calibration?
    public private(set) var shots: Int?
    public private(set) var paramsCustomize: ParamsCustomize?
    public private(set) var deleted: Bool?
    public private(set) var userDeleted: Bool?
    public private(set) var identifier: String?
    public private(set) var deviceId: String?
    public private(set) var userId: String?
    public private(set) var jobId: String?
    public private(set) var qasm: String?
    public private(set) var codeId: String?
    public private(set) var code: [String:AnyObject]?
    public var description: String {
        return self.json.description
    }

    public final class Result: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var date: String?
        public private(set) var data: Data?
        public var description: String {
            return self.json.description
        }

        public final class Data: CustomStringConvertible {

            public let json: [String: AnyObject]
            public private(set) var dataP: DataP?
            public private(set) var qasm: String?
            public private(set) var serialNumberDevice: String?
            public private(set) var time: Double?
            public var description: String {
                return self.json.description
            }

            public final class DataP: CustomStringConvertible {

                public let json: [String: AnyObject]
                public private(set) var qubits: [NSNumber]?
                public private(set) var labels: [String]?
                public private(set) var values: [NSNumber]?
                public var description: String {
                    return self.json.description
                }

                init(_ json: [String: AnyObject]) {
                    self.json = json
                    if let qubits = json["qubits"] as? [NSNumber] {
                        self.qubits = qubits
                    }
                    if let labels = json["labels"] as? [String] {
                        self.labels = labels
                    }
                    if let values = json["values"] as? [NSNumber] {
                        self.values = values
                    }
                }
            }

            init(_ json: [String: AnyObject]) {
                self.json = json
                if let dataP = json["p"] as? [String:AnyObject] {
                    self.dataP = DataP(dataP)
                }
                if let qasm = json["qasm"] as? String {
                    self.qasm = qasm
                }
                if let serialNumberDevice = json["serialNumberDevice"] as? String {
                    self.serialNumberDevice = serialNumberDevice
                }
                if let time = json["time"] as? NSNumber {
                    self.time = time.doubleValue
                }
            }
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let date = json["date"] as? String {
                self.date = date
            }
            if let data = json["data"] as? [String:AnyObject] {
                self.data = Data(data)
            }
        }
    }

    public final class Status: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var identifier: String?
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let identifier = json["id"] as? String {
                self.identifier = identifier
            }
        }
    }

    public final class ResultIP: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var ipString: String?
        public private(set) var city: String?
        public private(set) var country: String?
        public private(set) var continent: String?
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let ipString = json["ip"] as? String {
                self.ipString = ipString
            }
            if let city = json["city"] as? String {
                self.city = city
            }
            if let country = json["country"] as? String {
                self.country = country
            }
            if let continent = json["continent"] as? String {
                self.continent = continent
            }
        }
    }

    public final class Calibration: CustomStringConvertible {

        public let json: [String: AnyObject]
        public private(set) var date: String?
        public private(set) var device: String?
        public private(set) var fridgeTemperature: Double?
        public private(set) var properties: [Property]?
        public var description: String {
            return self.json.description
        }

        public final class Property: CustomStringConvertible {

            public let json: [String: AnyObject]
            public private(set) var values: [String:AnyObject]?
            public var description: String {
                return self.json.description
            }

            init(_ json: [String: AnyObject]) {
                self.json = json
                if let values = json["values"] as? [String:AnyObject] {
                    self.values = values
                }
            }
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
            if let date = json["date"] as? String {
                self.date = date
            }
            if let device = json["device"] as? String {
                self.device = device
            }
            if let fridgeTemperature = json["fridge_temperature"] as? NSNumber {
                self.fridgeTemperature = fridgeTemperature.doubleValue
            }
            if let properties = json["properties"] as? [[String:AnyObject]] {
                self.properties = []
                for property in properties {
                    self.properties!.append(Property(property))
                }
            }
        }
    }

    public final class ParamsCustomize: CustomStringConvertible {

        public let json: [String: AnyObject]
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
        }
    }

    init(_ json: [String: AnyObject], _ code: [String: AnyObject]? = nil) {
        self.json = json
        if let result = json["result"] as? [String:AnyObject] {
            self.result = Result(result)
        }
        if let startDate = json["startDate"] as? String {
            self.startDate = startDate
        }
        if let modificationDate = json["modificationDate"] as? NSNumber {
            self.modificationDate = modificationDate.intValue
        }
        if let time = json["time"] as? NSNumber {
            self.time = time.doubleValue
        }
        if let endDate = json["endDate"] as? String {
            self.endDate = endDate
        }
        if let typeCredits = json["typeCredits"] as? String {
            self.typeCredits = typeCredits
        }
        if let status = json["status"] as? [String:AnyObject] {
            self.status = Status(status)
        }
        if let resultIP = json["ip"] as? [String:AnyObject] {
            self.resultIP = ResultIP(resultIP)
        }
        if let calibration = json["calibration"] as? [String:AnyObject] {
            self.calibration = Calibration(calibration)
        }
        if let shots = json["shots"] as? NSNumber {
            self.shots = shots.intValue
        }
        if let paramsCustomize = json["paramsCustomize"] as? [String:AnyObject] {
            self.paramsCustomize = ParamsCustomize(paramsCustomize)
        }
        if let deleted = json["deleted"] as? NSNumber {
            self.deleted = deleted.boolValue
        }
        if let userDeleted = json["userDeleted"] as? NSNumber {
            self.deleted = userDeleted.boolValue
        }
        if let identifier = json["id"] as? String {
            self.identifier = identifier
        }
        if let deviceId = json["deviceId"] as? String {
            self.deviceId = deviceId
        }
        if let userId = json["userId"] as? String {
            self.userId = userId
        }
        if let jobId = json["jobId"] as? String {
            self.jobId = jobId
        }
        if let qasm = json["qasm"] as? String {
            self.qasm = qasm
        }
        if let codeId = json["codeId"] as? String {
            self.codeId = codeId
        }
        self.code = code
    }
}

/**
 Quantum Experience runExperiment result model
 */
public final class RunExperimentResult: CustomStringConvertible {

    public let json: [String: AnyObject]
    public private(set) var status: String?
    public private(set) var executionId: String?
    public private(set) var codeId: String?
    public private(set) var result: Result?
    public var description: String {
        return self.json.description
    }

    public final class Result: CustomStringConvertible {

        public let json: [String: AnyObject]
        public var description: String {
            return self.json.description
        }

        init(_ json: [String: AnyObject]) {
            self.json = json
        }
    }

    init(_ execution: [String: AnyObject]) {
        self.json = execution
        if let status = execution["status"] as? [String: AnyObject] {
            if let statusId = status["id"] as? String {
                self.status = statusId
            }
        }
        if let executionId = execution["id"] as? String {
            self.executionId = executionId
        }
        if let codeId = execution["codeId"] as? String {
            self.codeId = codeId
        }
        if let result = json["result"] as? [String:AnyObject] {
            self.result = Result(result)
        }
    }
}

/**
 Quantum Experience REST Access API
 */
public final class IBMQuantumExperience {

    /// Device Type.
    public enum Device {
        case simulator, real
    }

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
     - parameter device: Device type
     - parameter shots:
     - parameter maxCredits:
     - parameter responseHandler: Closure to be called upon completion
     */
    public func runJob(qasms: [String], device: Device, shots: Int, maxCredits: Int,
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
            var backend: [String:String] = [:]
            backend["name"] = (device == Device.real) ? "real" : "simulator"
            data["backend"] = backend as AnyObject
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
     - parameter device: Device type
     - parameter shots:
     - parameter maxCredits:
     - parameter responseHandler: Closure to be called upon completion
     */
    public func runJobToCompletion(qasms: [String], device: Device, shots: Int, maxCredits: Int,
                                   responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
        self.runJob(qasms: qasms, device: device, shots: shots, maxCredits: maxCredits) { (out, error) in
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

            self.getCompleteJob(jobid) { (result, error) in
                responseHandler(result, error)
            }
        }
    }

    /**
     Gets job information once its status changes from RUNNING. Asynchronous.

     - parameter jobId: job identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getCompleteJob(_ jobId: String, responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.getCompleteJob(jobId, responseHandler: responseHandler)
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
     - parameter device: Device type
     - parameter shots:
     - parameter name: Experiment name
     - parameter timeout:
     - parameter responseHandler: Closure to be called upon completion
     */
    public func runExperiment(qasm: String, device: Device, shots: Int, name: String? = nil, timeOut: Int = 60,
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
            let deviceType: String = (device == Device.real) ? "real" : "sim_trivial_2"
            self.request.post(path: "codes/execute", params: "&shots=\(shots)&deviceRunType=\(deviceType)",
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
                self.getCompleteResultFromExecution(executionId, ((timeOut > 300) ? 300 : timeOut)) { (out, error) in
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
