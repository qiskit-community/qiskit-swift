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

    private static let __names_device_ibmqxv2 = Set<String>(["ibmqx5qv2", "ibmqx2", "qx5qv2", "qx5q", "real"])
    private static let __names_device_ibmqxv3 = Set<String>(["ibmqx3"])
    private static let __names_device_simulator = Set<String>(["simulator", "sim_trivial_2", "ibmqx_qasm_simulator"])

    let req: Request

    /**
     Creates Quantum Experience object with a given configuration.
     
     - parameter token: API token
     - parameter config: Qconfig object
     */
    public init(_ token: String, _ config: Qconfig? = nil) throws {
        self.req = try Request(token,config)
    }

    init() throws {
        self.req = try Request()
    }

    /**
     Check if the name of a device is valid to run in QX Platform
     */
    private func _check_device(_ dev: String, _ endpoint: String) -> String? {
        let device = dev.lowercased()
        if endpoint == "experiment" {
            if IBMQuantumExperience.__names_device_ibmqxv2.contains(device) {
                return "real"
            }
            if IBMQuantumExperience.__names_device_ibmqxv3.contains(device) {
                return "ibmqx3"
            }
            if IBMQuantumExperience.__names_device_simulator.contains(device) {
                return "sim_trivial_2"
            }
            return nil
        }
        if endpoint == "job" {
            if IBMQuantumExperience.__names_device_ibmqxv2.contains(device) {
                return "real"
            }
            if IBMQuantumExperience.__names_device_ibmqxv3.contains(device) {
                return "ibmqx3"
            }
            if IBMQuantumExperience.__names_device_simulator.contains(device) {
                return "simulator"
            }
            return nil
        }
        if endpoint == "status" {
            if IBMQuantumExperience.__names_device_ibmqxv2.contains(device) {
                return "chip_real"
            }
            if IBMQuantumExperience.__names_device_ibmqxv3.contains(device) {
                return "ibmqx3"
            }
            if IBMQuantumExperience.__names_device_simulator.contains(device) {
                return "chip_simulator"
            }
            return nil
        }
        if endpoint == "calibration" {
            if IBMQuantumExperience.__names_device_ibmqxv2.contains(device) {
                return "Real5Qv2"
            }
            if IBMQuantumExperience.__names_device_ibmqxv3.contains(device) {
                return "ibmqx3"
            }
        }
        return nil
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
     Beautify the calibrations returned by QX platform
     */
    private func _beautify_calibration_parameters(_ cals: [String:Any], _ device: String) -> [String:Any] {
        var ret: [String:Any] = [:]
        ret["name"] = device 
        var calibration_date: String? = nil
        var units: [String:Any] = [:]
        for (key,val) in cals {
            guard let attrs = val as? [[String:Any]] else {
                continue
            }
            if key == "fridge_temperature" {
                for attr in attrs {
                    if let value = attr["value"] as? String {
                        ret["fridgeTemperature"] = Double(value)! 
                        if var unit = attr["units"] as? String {
                            if unit == "Kelvin" {
                                unit = "K"
                            }
                            units["fridgeTemperature"] = unit 
                        }
                    }
                    if let date = attr["date"] as? Double {
                        calibration_date = String(date)
                    }
                }
                continue
            }
            if key.hasPrefix("Q") {
                let new_key = "Q" + String(Int(key.replacingOccurrences(of:"Q", with: ""))! - 1)
                var map: [String:Any] = [:]
                ret[new_key] = map 
                for attr in attrs {
                    if let label = attr["label"] as? String {
                        if let value = attr["value"] as? String {
                            if label.hasPrefix("f") {
                                map = ret[new_key] as! [String:Any]
                                map["frequency"] = Double(value)! 
                                ret[new_key] = map 
                                if let unit = attr["units"] as? Double {
                                    units["frequency"] = String(unit) 
                                }
                            }
                            if label.hasPrefix("t_1") {
                                map = ret[new_key] as! [String:Any]
                                map["t1"] = Double(value)! 
                                ret[new_key] = map 
                                if var unit = attr["units"] as? String {
                                    if unit == "microseconds" {
                                        unit = "us"
                                    }
                                    units["tx"] = unit 
                                }
                            }
                            if label.hasPrefix("t_2") {
                                map = ret[new_key] as! [String:Any]
                                map["t2"] = Double(value)! 
                                ret[new_key] = map 
                                if var unit = attr["units"] as? String {
                                    if unit == "microseconds" {
                                        unit = "us"
                                    }
                                    units["tx"] = unit 
                                }
                            }
                        }
                    }
                    if calibration_date == nil {
                        if let date = attr["date"] as? String {
                            calibration_date = date
                        }
                    }
                }
            }
        }
        if calibration_date != nil {
            ret["coherenceStartTime"] = calibration_date! 
        }

        // TODO: Get from new calibrations files
        ret["singleQubitGateTime"] = Int(80) 
        ret["units"] = units 

        return ["backend": ret ]
    }

    /**
     Beautify the calibrations returned by QX platform [[String:Any]]
     */
    private func _beautify_calibration(_ cals: [String:Any], _ device: String) -> [String:Any] {
        var ret: [String:Any] = [:]
        ret["name"] = device 
        var calibration_date: String? = nil
        var coupling_map: [String:[Int]] = [:]
        for (key,value) in cals {
            if key.hasPrefix("CR") {
                let qubits = key.replacingOccurrences(of:"CR", with:"").components(separatedBy:"_")
                let qubit_from = Int(qubits[0])! - 1
                let qubit_to = Int(qubits[1])! - 1
                let key_qubit = String(qubit_from)
                if coupling_map[key_qubit] == nil {
                    coupling_map[key_qubit] = []
                }
                coupling_map[key_qubit]!.append(qubit_to)
                let new_key = "CX" + String(qubit_from) + "_" + String(qubit_to)
                var map: [String:Any] = [:]
                ret[new_key] = map 
                let attrs = value as! [[String:Any]]
                for attr in attrs {
                    if let label = attr["label"] as? String {
                        if label.hasPrefix("e_g") {
                            if let value = attr["value"] as? String {
                                map = ret[new_key] as! [String:Any]
                                map["gateError"] = Double(value)! 
                                ret[new_key] = map 
                            }
                        }
                    }
                    if calibration_date == nil {
                        if let date = attr["date"] as? String {
                            calibration_date = date
                        }
                    }
                }
                continue
            }
            if key.hasPrefix("Q") {
                let new_key = "Q" + String(Int(key.replacingOccurrences(of:"Q", with:""))!-1)
                var map: [String:Any] = [:]
                ret[new_key] = map 
                let attrs = value as! [[String:Any]]
                for attr in attrs {
                    if let label = attr["label"] as? String {
                        if let value = attr["value"] as? String {
                            if label.hasPrefix("e_g")  {
                                map = ret[new_key] as! [String:Any]
                                map["gateError"] = Double(value)! 
                                ret[new_key] = map 
                            }
                            if label.hasPrefix("e_r") {
                                map = ret[new_key] as! [String:Any]
                                map["readoutError"] = Double(value)! 
                                ret[new_key] = map 
                            }
                        }
                    }
                    if calibration_date == nil {
                        if let date = attr["date"] as? String {
                            calibration_date = date
                        }
                    }

                }
            }
        }
        if calibration_date != nil {
            ret["calibrationStartTime"] = calibration_date! 
        }
        if !coupling_map.isEmpty {
            ret["couplingMap"] = coupling_map 
        }

        return ["backend": ret ]
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
                responseHandler(result, error)
            }
        }
    }

    /**
     Gets code information. Asynchronous.

     - parameter idCode: code identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    private func get_code(_ idCode: String, responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
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
                               device: String = "simulator",
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
            var data: [String : Any] = [:]
            var q: String = qasm.replacingOccurrences(of: "IBMQASM 2.0;", with: "")
            q = q.replacingOccurrences(of: "OPENQASM 2.0;", with: "")
            data["qasm"] = q 
            data["codeType"] = "QASM2" 
            if let n = name {
                data["name"] = n 
            } else {
                let date = Date()
                let calendar = Calendar.current
                let c = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                data["name"] = "Experiment #\(c.year!)\(c.month!)\(c.day!)\(c.hour!)\(c.minute!)\(c.second!))"
                    
            }
            guard let device_type = self._check_device(device, "experiment") else {
                responseHandler(nil,IBMQuantumExperienceError.missingDevice(device: device))
                return
            }
            if !IBMQuantumExperience.__names_device_simulator.contains(device) && seed != nil {
                responseHandler(nil,IBMQuantumExperienceError.errorSeed(device: device))
                return
            }
            if seed != nil {
                if String(seed!).characters.count >= 11 {
                    responseHandler(nil,IBMQuantumExperienceError.errorSeedLength)
                    return
                }
                self.req.post(path: "codes/execute",
                              params: "&shots=\(shots)&seed=\(seed!)&deviceRunType=\(device_type)",
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
                              params: "&shots=\(shots)&deviceRunType=\(device_type)",
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
        print("Status: \(status)")
        guard let id_execution = execution["id"] as? String else {
            responseHandler(nil, IBMQuantumExperienceError.missingExecutionId)
            return
        }
        var result: [String:Any] = [:]
        respond["status"] = status
        respond["idExecution"] = id_execution
        respond["idCode"] = execution["codeId"]

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
                }
            }
            responseHandler(respond, nil)
            return
        }
        if status == "ERROR" {
            responseHandler(respond, nil)
            return
        }
        self.getCompleteResultFromExecution(id_execution, ((timeout > 300) ? 300 : timeout)) { (out, error) in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            if let result = out {
                respond["status"] = "DONE"
                respond["result"] = result
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
                        device: String = "simulator",
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

            guard let device_type = self._check_device(device, "job") else {
                responseHandler(nil,IBMQuantumExperienceError.missingDevice(device: device))
                return
            }
            if !IBMQuantumExperience.__names_device_simulator.contains(device) && seed != nil {
                responseHandler(nil,IBMQuantumExperienceError.errorSeed(device: device))
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
            backendDict["name"] = device_type
            data["backend"] = backendDict

            self.req.post(path: "Jobs", data: data) { (out, error) -> Void in
                guard let json = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                responseHandler(json, error)
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
     Get the status of a chip
     */
    public func device_status(_ device: String = "ibmqx2",
                       responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        guard let device_type = self._check_device(device, "status") else {
            responseHandler(nil,IBMQuantumExperienceError.missingDevice(device: device))
            return
        }
        self.req.get(path:"Status/queue?device=\(device_type)",with_token: false) { (out, error) -> Void in
            guard let json = out as? [String:Any] else {
                responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                return
            }
            responseHandler(["available" : (json["state"] != nil) ], error)
        }
    }

    /**
     Get the calibration of a real chip
     */
    public func device_calibration(_ device: String = "ibmqx2",
                            responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            guard let device_type = self._check_device(device, "calibration") else {
                responseHandler(nil,IBMQuantumExperienceError.missingRealDevice(device: device))
                return
            }
            self.req.get(path:"DeviceStats/statsByDevice/\(device_type)",params:"&raw=true") { (out, error) -> Void in
                guard let json = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                var dev = device
                if device_type == "Real5Qv2" {
                    dev = "ibmqx2"
                }
                responseHandler(self._beautify_calibration(json, dev),error)
            }
        }
    }

    /**
     Get the parameters of calibration of a real chip
     */
    public func device_parameters(_ device: String = "ibmqx2",
                                  responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            guard let device_type = self._check_device(device, "calibration") else {
                responseHandler(nil,IBMQuantumExperienceError.missingRealDevice(device: device))
                return
            }
            self.req.get(path: "DeviceStats/statsByDevice/\(device_type)", params: "&raw=true") { (out, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                guard let json = out as? [String:Any] else {
                    responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                var dev = device
                if device_type == "Real5Qv2" {
                    dev = "ibmqx2"
                }
                let ret = self._beautify_calibration_parameters(json, dev)
                responseHandler(ret, error)
            }
        }
    }

    /**
     Get the devices availables to use in the QX Platform
     */
    public func available_devices(responseHandler: @escaping ((_:[[String:Any]]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            self.req.get(path: "Devices/list") { (out, error) -> Void in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                guard let devices_real = out as? [[String:Any]] else {
                    responseHandler(nil,IBMQuantumExperienceError.missingDevices)
                    return
                }
                var respond: [[String:Any]] = []
                var sim: [String:Any] = [:]
                sim["name"] = "simulator"
                sim["type"] = "Simulator"
                sim["num_qubits"] = 24
                respond.append(sim)
                self.available_devices(devices_real, respond, responseHandler)
            }
        }
    }

    private func available_devices(_ devices: [[String:Any]],
                                   _ respond: [[String:Any]],
                _ responseHandler: @escaping ((_:[[String:Any]]?, _:IBMQuantumExperienceError?) -> Void)) {
        if devices.isEmpty {
            responseHandler(respond, nil)
            return
        }
        var devs = devices
        let device = devs.remove(at: 0)
        guard let topologyId = device["topologyId"] as? String else {
            self.available_devices(devs,respond,responseHandler)
            return
        }
        var real: [String:Any] = [:]
        real["type"] = "Real"
        real["name"] = device["serialNumber"]
        if let n = real["name"] as? String {
            if n == "Real5Qv2" {
                real["name"] = "ibmqx2"
            }
        }
        self.req.get(path: "Topologies/\(topologyId)") { (out, error) -> Void in
            if error != nil {
                responseHandler(nil, error)
                return
            }
            guard let topology = out as? [String:Any] else {
                responseHandler(nil,IBMQuantumExperienceError.invalidResponseData)
                return
            }
            if let top = topology["topology"] as? [String:Any] {
                if let adjacencyMatrix = top["adjacencyMatrix"] {
                    real["topology"] = adjacencyMatrix
                }
            }
            real["num_qubits"] = topology["qubits"]
            var resp = respond
            resp.append(real)
            self.available_devices(devs,resp,responseHandler)
        }
    }
}
