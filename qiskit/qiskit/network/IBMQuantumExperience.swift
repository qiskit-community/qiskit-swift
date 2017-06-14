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
    private func _beautify_calibration_parameters(_ cals: [String:[[String:AnyObject]]], _ device: String) -> [String:AnyObject] {
        var ret: [String:AnyObject] = [:]
        ret["name"] = device as AnyObject
        var calibration_date: String? = nil
        var units: [String:AnyObject] = [:]
        for (key,attrs) in cals {
            if key == "fridge_temperature" {
                for attr in attrs {
                    if let value = attr["value"] as? String {
                        ret["fridgeTemperature"] = Double(value)! as AnyObject
                        if var unit = attr["units"] as? String {
                            if unit == "Kelvin" {
                                unit = "K"
                            }
                            units["fridgeTemperature"] = unit as AnyObject
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
                var map: [String:AnyObject] = [:]
                ret[new_key] = map as AnyObject
                for attr in attrs {
                    if let label = attr["label"] as? String {
                        if let value = attr["value"] as? String {
                            if label.hasPrefix("f") {
                                map = ret[new_key] as! [String:AnyObject]
                                map["frequency"] = Double(value)! as AnyObject
                                ret[new_key] = map as AnyObject
                                if let unit = attr["units"] as? Double {
                                    units["frequency"] = String(unit) as AnyObject
                                }
                            }
                            if label.hasPrefix("t_1") {
                                map = ret[new_key] as! [String:AnyObject]
                                map["t1"] = Double(value)! as AnyObject
                                ret[new_key] = map as AnyObject
                                if var unit = attr["units"] as? String {
                                    if unit == "microseconds" {
                                        unit = "us"
                                    }
                                    units["tx"] = unit as AnyObject
                                }
                            }
                            if label.hasPrefix("t_2") {
                                map = ret[new_key] as! [String:AnyObject]
                                map["t2"] = Double(value)! as AnyObject
                                ret[new_key] = map as AnyObject
                                if var unit = attr["units"] as? String {
                                    if unit == "microseconds" {
                                        unit = "us"
                                    }
                                    units["tx"] = unit as AnyObject
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
            ret["coherenceStartTime"] = calibration_date! as AnyObject
        }

        // TODO: Get from new calibrations files
        ret["singleQubitGateTime"] = Int(80) as AnyObject
        ret["units"] = units as AnyObject

        return ["backend": ret as AnyObject]
    }

    /**
     Beautify the calibrations returned by QX platform [[String:AnyObject]]
     */
    private func _beautify_calibration(_ cals: [String:AnyObject], _ device: String) -> [String:AnyObject] {
        var ret: [String:AnyObject] = [:]
        ret["name"] = device as AnyObject
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
                var map: [String:AnyObject] = [:]
                ret[new_key] = map as AnyObject
                let attrs = value as! [[String:AnyObject]]
                for attr in attrs {
                    if let label = attr["label"] as? String {
                        if label.hasPrefix("e_g") {
                            if let value = attr["value"] as? String {
                                map = ret[new_key] as! [String:AnyObject]
                                map["gateError"] = Double(value)! as AnyObject
                                ret[new_key] = map as AnyObject
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
                var map: [String:AnyObject] = [:]
                ret[new_key] = map as AnyObject
                let attrs = value as! [[String:AnyObject]]
                for attr in attrs {
                    if let label = attr["label"] as? String {
                        if let value = attr["value"] as? String {
                            if label.hasPrefix("e_g")  {
                                map = ret[new_key] as! [String:AnyObject]
                                map["gateError"] = Double(value)! as AnyObject
                                ret[new_key] = map as AnyObject
                            }
                            if label.hasPrefix("e_r") {
                                map = ret[new_key] as! [String:AnyObject]
                                map["readoutError"] = Double(value)! as AnyObject
                                ret[new_key] = map as AnyObject
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
            ret["calibrationStartTime"] = calibration_date! as AnyObject
        }
        if !coupling_map.isEmpty {
            ret["couplingMap"] = coupling_map as AnyObject
        }

        return ["backend": ret as AnyObject]
    }

    /**
     Gets execution information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getExecution(_ idExecution: String,
                             responseHandler: @escaping ((_:GetExecutionResult?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.req.get(path: "Executions/\(idExecution)") { (out, error) -> Void in
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
                                       responseHandler: @escaping ((_:GetExecutionResult.Result?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.req.get(path: "Executions/\(idExecution)") { (out, error) -> Void in
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
    private func getCode(_ idCode: String, responseHandler: @escaping ((_:[String:AnyObject], _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler([:], error)
                }
                return
            }
            self.req.get(path: "Codes/\(idCode)") { (code, error) -> Void in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(code, error)
                    }
                    return
                }
                self.req.get(path:"Codes/\(idCode)/executions",
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
     Gets image. Asynchronous.

     - parameter idCode: Code Identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getImageCode(_ idCode: String,
                             responseHandler: @escaping ((_:[String:AnyObject]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.req.get(path: "Codes/\(idCode)/export/png/url") { (image, error) -> Void in
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
                              responseHandler: @escaping ((_:RunExperimentResult?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
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
            self.req.post(path: "codes/execute", params: "&shots=\(shots)&deviceRunType=\(backend)",
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

    /**
     Runs a job. Asynchronous.

     - parameter qasms: Array of qasm code string
     - parameter backend: Backend type
     - parameter shots:
     - parameter maxCredits:
     - parameter responseHandler: Closure to be called upon completion
     */
    public func run_job(qasms: [[String:AnyObject]], backend: String, shots: Int, maxCredits: Int,
                       responseHandler: @escaping ((_:RunJobResult?, _:IBMQuantumExperienceError?) -> Void)) {

        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            var data: [String : AnyObject] = [:]
            var qasmArray: [[String:AnyObject]] = []
            for var dict in qasms {
                if var value = dict["qasm"] as? String {
                    value = value.replacingOccurrences(of: "IBMQASM 2.0;", with: "")
                    dict["qasm"] = value.replacingOccurrences(of: "OPENQASM 2.0;", with: "") as AnyObject
                }
                qasmArray.append(dict)
            }
            data["qasms"] = qasmArray as AnyObject
            data["shots"] = shots as AnyObject
            data["maxCredits"] = maxCredits as AnyObject
            var backendDict: [String:String] = [:]
            backendDict["name"] = backend
            data["backend"] = backendDict as AnyObject
            self.req.post(path: "Jobs", data: data) { (json, error) -> Void in
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
    public func getJob(jobId: String, responseHandler: @escaping ((_:GetJobResult?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, error)
                }
                return
            }
            self.req.get(path: "Jobs/\(jobId)") { (json, error) -> Void in
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
    public func runJobToCompletion(qasms: [[String:AnyObject]], backend: String, shots: Int, maxCredits: Int,
                                   wait: Int = 5, timeout: Int = 60,
                                   responseHandler: @escaping ((_:GetJobResult?, _:IBMQuantumExperienceError?) -> Void)) {
        self.run_job(qasms: qasms, backend: backend, shots: shots, maxCredits: maxCredits) { (out, error) in
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
                           _ responseHandler: @escaping ((_:GetJobResult?, _:IBMQuantumExperienceError?) -> Void)) {
        self.waitForJob(jobId, wait, timeout, 0, responseHandler)
    }

    private func waitForJob(_ jobId: String, _ wait: Int, _ timeout: Int, _ elapsed: Int,
                            _ responseHandler: @escaping ((_:GetJobResult?, _:IBMQuantumExperienceError?) -> Void)) {
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

    private func getCompleteResultFromExecution(_ idExecution: String, _ timeOut: Int,
                                                responseHandler:
                                                @escaping ((_:GetExecutionResult.Result?, _:IBMQuantumExperienceError?) -> Void)) {
        self.checkCredentials(request: self.req) { (error) -> Void in
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
     Get the status of a chip
     */
    func device_status(_ device: String = "ibmqx2",
                       responseHandler: @escaping ((_:[String:AnyObject]?, _:IBMQuantumExperienceError?) -> Void)) {
        guard let device_type = self._check_device(device, "status") else {
            responseHandler([:],IBMQuantumExperienceError.missingDevice(device: device))
            return
        }
        self.req.get(path:"Status/queue?device=\(device_type)",with_token: false) { (json, error) -> Void in
            responseHandler(["available" : (json["state"] != nil) as AnyObject], error)
        }
    }

    /**
     Get the calibration of a real chip
     */
    func device_calibration(_ device: String = "ibmqx2",
                            responseHandler: @escaping ((_:[String:AnyObject]?, _:IBMQuantumExperienceError?) -> Void)) {
        if !self._check_credentials() {
            responseHandler([:],IBMQuantumExperienceError.missingTokenId)
            return
        }
        guard let device_type = self._check_device(device, "calibration") else {
            responseHandler([:],IBMQuantumExperienceError.missingRealDevice(device: device))
            return
        }
        self.req.get(path:"DeviceStats/statsByDevice/\(device_type)",params:"&raw=true") { (json, error) -> Void in
            var dev = device
            if device_type == "Real5Qv2" {
                dev = "ibmqx2"
            }
            responseHandler(self._beautify_calibration(json, dev),error)
        }
    }

    /**
     Get the parameters of calibration of a real chip
     */
/*    public func device_parameters(_ device: String = "ibmqx2",
                                  responseHandler: @escaping ((_:[String:AnyObject]?, _:IBMQuantumExperienceError?) -> Void)) {
        if !self._check_credentials() {
            responseHandler([:],IBMQuantumExperienceError.missingTokenId)
            return
        }
        let device_type = self._check_device(device, "calibration")
        if device_type == nil {
            respond = {}
            respond["error"] = str("Device " +
                    device +
                    " not exits in Quantum Experience" +
                    " Real Devices. Only allow ibmqx2")
            return respond
        }
        ret = self.req.get("/DeviceStats/statsByDevice/" + device_type,
                            "&raw=true")
        var dev = device
        if device_type == "Real5Qv2" {
            dev = "ibmqx2"
        }
        ret = self._beautify_calibration_parameters(ret, dev)
        return ret
    }
*/
    /**
     Get the devices availables to use in the QX Platform
     */
/*    public func available_devices(responseHandler: @escaping ((_:[String:AnyObject]?, _:IBMQuantumExperienceError?) -> Void)) {
        if !self._check_credentials() {
            responseHandler([:],IBMQuantumExperienceError.missingTokenId)
            return
        }
        devices_real = self.req.get("/Devices/list")
        respond = []
        sim = {}
        sim["name"] = "simulator"
        sim["type"] = "Simulator"
        sim["num_qubits"] = 24
        respond.append(sim)
        for device in devices_real {
            real = {}
            real["type"] = "Real"
            real["name"] = device["serialNumber"]
            if real["name"] == "Real5Qv2" {
                real["name"] = "ibmqx2"
            }
            topology = self.req.get("/Topologies/"+device["topologyId"])
            if (("topology" in topology) and ("adjacencyMatrix" in topology["topology"])) {
                real["topology"] = topology["topology"]["adjacencyMatrix"]
            }
            real["num_qubits"] = topology["qubits"]
            respond.append(real)
        }
        return respond
    }
*/
}
