//
//  IBMQuantumExperienceResults.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

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
