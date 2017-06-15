//
//  QuantumProgram.swift
//  qiskit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Quantum Program Class
 */
public final class QuantumProgram {

    final class QCircuit {
        let name: String
        let circuit: QuantumCircuit
        var execution: [String:Any] = [:]

        init(_ name: String, _ circuit: QuantumCircuit) {
            self.name = name
            self.circuit = circuit
        }
    }

    final class QProgram {
        var circuits: [String: QCircuit] = [:]
    }

    private class APIConfig {
        var token: String = ""
        var url: URL? = nil
    }

    private static let __ONLINE_DEVICES = Set<String>(["real", "ibmqx2", "ibmqx3", "simulator", "ibmqx_qasm_simulator"])
    private static let __LOCAL_DEVICES = Set<String>(["local_unitary_simulator", "local_qasm_simulator"])

    public let name: String
    private var config: Qconfig
    private var __quantum_program: QProgram
    private var __api: IBMQuantumExperience
    private var __api_config: APIConfig = APIConfig()
    private var __quantum_registers: [String: QuantumRegister] = [:]
    private var __classical_registers: [String: ClassicalRegister] = [:]
    private var __init_circuit: QuantumCircuit? = nil
    private var __last_device_backend: String = ""
    private var __to_execute: [String:[[String:Any]]] = [:]

    public init(specs: [String:Any]? = nil, name: String = "") throws {
        self.name = name
        self.config  = try Qconfig()
        self.__quantum_program = QProgram()
        self.__api = try IBMQuantumExperience("",self.config)
        if let s = specs {
            try self.__init_specs(s)
        }
    }

    /**
     Return the program specs
     */
    public func get_api_config() -> Qconfig? {
        return self.__api.req.credential.config
    }

    private func _setup_api(_ token: String, _ url: String?) throws {
        let config = (url != nil) ? try Qconfig(url: url!) : try Qconfig()
        self.__api = try IBMQuantumExperience(token, config)
    }

    /**
     Set the API conf
     */
    public func set_api(token: String? = nil, url: String? = nil) throws {
        if let t = token {
            self.__api_config.token = t
        }
        if let u = url {
            guard let url = URL(string: u) else {
                throw IBMQuantumExperienceError.invalidURL(url: u)
            }
            self.__api_config.url = url
        }
        var urlString: String? = nil
        if let u = self.__api_config.url {
            urlString = u.absoluteString
        }
        try self._setup_api(self.__api_config.token, urlString)
    }

    /**
     Set the API Token
     */
    public func set_api_token(_ token: String) throws {
        try self.set_api(token: token)
    }

    /**
     Set the API url
     */
    public func set_api_url(_ url: String) throws {
        try self.set_api(url: url)
    }

    /**
     Return the online device status via QX API call
     device is the name of the real chip
    */
    public func get_device_status(_ device: String,
                                  responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        if QuantumProgram.__ONLINE_DEVICES.contains(device) {
            self.__api.device_status(device,responseHandler:responseHandler)
            return
        }
        responseHandler(nil,IBMQuantumExperienceError.errorDevice(device: device))
    }

    /**
     Return the online device calibrations via QX API call
     device is the name of the real chip
     */
    public func get_device_calibration(_ device: String,
                                       responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        if QuantumProgram.__ONLINE_DEVICES.contains(device) {
            self.__api.device_calibration(device,responseHandler:responseHandler)
            return
        }
        responseHandler(nil,IBMQuantumExperienceError.errorDevice(device: device))
    }

    /**
     Create a new set of Quantum Register
     */
    private func create_quantum_registers(_ name: String, _ size: Int) throws -> QuantumRegister {
        try self.__quantum_registers[name] = QuantumRegister(name, size)
        return self.__quantum_registers[name]!
    }

    /**
     Create a new set of Quantum Registers based in a array of that
     */
    private func create_quantum_registers_group(_ registers_array:[Any]) throws -> [QuantumRegister] {
        var new_registers:[QuantumRegister] = []
        for reg in registers_array {
            if let register = reg as? [String:Any] {
                if let name = register["name"] as? String {
                    if let size = register["size"] as? NSNumber {
                        try new_registers.append(self.create_quantum_registers(name,size.intValue))
                    }
                }
            }
        }
        return new_registers
    }

    /**
     Create a new set of Classical Registers
     */
    private func  create_classical_registers(_ name: String, _ size: Int) throws -> ClassicalRegister {
        try self.__classical_registers[name] = ClassicalRegister(name, size)
        return self.__classical_registers[name]!
    }

    /**
     Create a new set of Classical Registers based in a array of that
     */
    private func  create_classical_registers_group(_ registers_array:[Any]) throws -> [ClassicalRegister] {
        var new_registers:[ClassicalRegister] = []
        for reg in registers_array {
            if let register = reg as? [String:Any] {
                if let name = register["name"] as? String {
                    if let size = register["size"] as? NSNumber {
                        new_registers.append(try self.create_classical_registers(name,size.intValue))
                    }
                }
            }
        }
        return new_registers
    }

    /**
     Create a new Quantum Circuit into the Quantum Program
     name is a string, the name of the circuit
     qregisters is a Array of Quantum Registers
     cregisters is a Array of Classical Registers
     */
    private func create_circuit(name: String,
                                qregisters: [QuantumRegister] = [],
                                cregisters: [ClassicalRegister] = [],
                                circuit_object: QuantumCircuit = QuantumCircuit()) throws -> QuantumCircuit {
        self.__quantum_program.circuits[name] = QCircuit(name, circuit_object)

        for register in qregisters {
            try self.__quantum_program.circuits[name]!.circuit.add([register])
        }
        for register in cregisters {
            try self.__quantum_program.circuits[name]!.circuit.add([register])
        }
        return self.__quantum_program.circuits[name]!.circuit
    }

    /**
     Return a Quantum Register by nam
     */
    public func get_quantum_registers(_ name: String) -> QuantumRegister? {
        return self.__quantum_registers[name]
    }

    /**
     Return a Classical Register by name
     */
    public func get_classical_registers(_ name: String) -> ClassicalRegister? {
        return self.__classical_registers[name]
    }

    /**
     Return a Circuit Object by name
     */
    public func get_circuit(_ name: String) -> QuantumCircuit? {
        if let qCircuit =  self.__quantum_program.circuits[name] {
            return qCircuit.circuit
        }
        return nil
    }

    /**
     Return the basic elements, Circuit, Quantum Registers, Classical Registers    
     */
    public func get_quantum_elements(_ specs:[String: Any] = [:]) -> (QuantumCircuit?,QuantumRegister?,ClassicalRegister?) {
        var qRegister: QuantumRegister? = nil
        if let tuple = self.__quantum_registers.first {
            qRegister = tuple.value
        }
        var cRegister: ClassicalRegister? = nil
        if let tuple = self.__classical_registers.first {
            cRegister = tuple.value
        }
        return (self.__init_circuit,qRegister,cRegister)
    }

    /**
     Load qasm file
     qasm_file qasm file name
     */
    public func load_qasm(name: String = "", qasm_file: String? = nil, basis: String? = nil) throws {
    /*    guard let file = qasm_file else {
            throw QISKitException.missingFileName
        }
        var basis_gates: String = "u1,u2,u3,cx,id"  // QE target basis
        if let b = basis {
            basis_gates = b
        }
        var n = name
        if n == "" {
            n = file
        }
*/
        //let circuit_object = qasm.Qasm(filename=qasm_file).parse() // Node (AST)

        // TODO: add method to convert to QuantumCircuit object from Node
        //self.__quantum_program.circuits[n] = QCircuit(n, circuit_object)
    }

    /**
     Populate the Quantum Program Object with initial Specs
     */
    private func __init_specs(_ specs:[String: Any]) throws {
        if let api = specs["api"] as? [String:Any] {
            if let token = api["token"] as? String {
                self.__api_config.token = token
            }
            if let u = api["url"] as? String {
                guard let url = URL(string: u) else {
                    throw IBMQuantumExperienceError.invalidURL(url: u)
                }
                self.__api_config.url = url
            }
        }

        var quantumr:[QuantumRegister] = []
        var classicalr:[ClassicalRegister] = []
        if let circuits = specs["circuits"] as? [Any] {
            for circ in circuits {
                if let circuit = circ as? [String:Any] {
                    if let qregs = circuit["quantum_registers"] as? [Any] {
                        quantumr = try self.create_quantum_registers_group(qregs)
                    }
                    if let cregs = circuit["classical_registers"] as? [Any] {
                        classicalr = try self.create_classical_registers_group(cregs)
                    }
                    var name: String = "name"
                    if let n = circuit["name"] as? String {
                        name = n
                    }
                    self.__init_circuit = try self.create_circuit(name:name,qregisters:quantumr,cregisters:classicalr)
                }
            }
            return
        }

        var qReg: QuantumRegister? = nil
        if let register = specs["quantum_registers"] as? [String:Any] {
            if let name = register["name"] as? String {
                if let size = register["size"] as? NSNumber {
                    qReg = try self.create_quantum_registers(name,size.intValue)
                }
            }
        }
        var cReg: ClassicalRegister? = nil
        if let register = specs["classical_registers"] as? [String:Any] {
            if let name = register["name"] as? String {
                if let size = register["size"] as? NSNumber {
                    cReg = try self.self.create_classical_registers(name,size.intValue)
                }
            }
        }
        if qReg != nil && cReg != nil {
            var name: String = "name"
            if let n = specs["name"] as? String {
                name = n
            }
            _ = try self.create_circuit(name:name,qregisters:[qReg!], cregisters:[cReg!])
        }
    }

    /**
     Add a new circuit based in a Object representation.
     name is the name or index of one circuit.
     */
    public func add_circuit(_ name: String, _ circuit_object: QuantumCircuit) -> QuantumCircuit {
        self.__quantum_program.circuits[name] = QCircuit(name, circuit_object)
        return circuit_object
    }

    /**
     Get image circuit representation from API
    */
    private func get_qasm_image(_ circuit: QuantumCircuit) {
    }

    /**
     get the circut by name.
     name of the circuit
     */
    public func get_qasm(_ name: String) throws -> String {
        guard let qCircuit = self.__quantum_program.circuits[name] else {
            throw QISKitException.missingCircuit
        }
        return qCircuit.circuit.qasm()
    }

    /**
     get the circut by name.
     name of the circuit
     */
    public func get_qasms(_ list_circuit_name: [String]) throws -> [String] {
        var qasm_source: [String] = []
        for name in list_circuit_name {
            qasm_source.append(try self.get_qasm(name))
        }
        return qasm_source
    }

    /**
     Unroll the code
     circuit is circuits to unroll
     basis_gates are the base gates, which by default are: u1,u2,u3,cx,id
     */
    func unroller_code(_ circuitQasm: String, _ basis_gates: String? = nil) throws -> (String,Circuit) {
        var basis = "u1,u2,u3,cx,id"  // QE target basis
        if let b = basis_gates {
            basis = b
        }
        let unrolled_circuit = Unroller(Qasm(data: circuitQasm).parse(),
                                        CircuitBackend(basis.components(separatedBy:",")))
        try unrolled_circuit.execute()

        let circuit_unrolled = (unrolled_circuit.backend as! CircuitBackend).circuit  // circuit DAG
        let qasm_source = try circuit_unrolled.qasm(qeflag: true)
        return (qasm_source, circuit_unrolled)
    }

    /**
     Compile the name_of_circuits by names.
     name_of_circuits is a list of circuit names to compile.
     device is the target device name.
     basis_gates are the base gates by default are: u1,u2,u3,cx,id
     coupling_map is the adjacency list for coupling graph
     This method adds elements of the following form to the self.__to_execute
     list corresponding to the device:
     --device name (string)--: [
         {
         "name": --circuit name (string)--,
         "coupling_map": --adjacency list (dict)--,
         "basis_gates": --comma separated gate names (string)--,
         "compiled_circuit": --compiled quantum circuit (currently QASM text)--,
         "shots": --shots (int)--,
         "max_credits": --credits (int)--
         "seed": --initial seed for the simulator (int) --
         },
         ...
        ]
     }
     */
    public func compile(_ name_of_circuits: [String],
                 device: String = "local_qasm_simulator",
                 shots: Int = 1024,
                 max_credits: Int = 3,
                 basis_gates: String? = nil,
                 coupling_map: [Int:[Int]]? = nil,
                 seed: Double? = nil) throws {
        if name_of_circuits.isEmpty {
            throw QISKitException.missingCircuits
        }

        for name in name_of_circuits {
            guard let qCircuit = self.__quantum_program.circuits[name] else {
                throw QISKitException.missingQuantumProgram(name: name)
            }

            // TODO: The circuit object has to have .qasm() method (be careful)
            var (qasm_compiled, dag_unrolled) = try self.unroller_code(qCircuit.circuit.qasm(), basis_gates)
            if coupling_map != nil {
                print("pre-mapping properties: \(try dag_unrolled.property_summary())")
                // Insert swap gates
                let coupling = try Coupling(coupling_map)
                var (dag_unrolled, final_layout) = try Mapping.swap_mapper(dag_unrolled, coupling)
                print("layout: \(final_layout)")
                // Expand swaps
                (qasm_compiled, dag_unrolled) = try self.unroller_code(try dag_unrolled.qasm())
                // Change cx directions
                dag_unrolled = try Mapping.direction_mapper(dag_unrolled,coupling)
                // Simplify cx gates
                try Mapping.cx_cancellation(dag_unrolled)
                // Simplify single qubit gates
                dag_unrolled = try Mapping.optimize_1q_gates(dag_unrolled)
                qasm_compiled = try dag_unrolled.qasm(qeflag: true)
                print("post-mapping properties: \(try dag_unrolled.property_summary())")
            }
            // TODO: add timestamp, compilation
            var jobs: [[String:Any]] = []
            if let arr = self.__to_execute[device] {
                jobs = arr
            }
            var job: [String:Any] = [:]
            job["name"] = name 
            if let map = coupling_map {
                job["coupling_map"] = map 
            }
            if let basis = basis_gates {
                job["basis_gates"] = basis 
            }
            job["shots"] = shots 
            job["max_credits"] = max_credits 
            // TODO: This will become a new compiled circuit object in the
            //      future. See future improvements at the top of this
            //     file.
            job["compiled_circuit"] = qasm_compiled 
            job["seed"] = Random.random() 
            if seed != nil {
                job["seed"] = seed! 
            }
            jobs.append(job)
            self.__to_execute[device] = jobs
        }
    }

    /**
     Get the compiled qasm for the named circuit and device.
     If device is None, it defaults to the last device.
    */
    public func get_compiled_qasm(_ name: String, _ device: String? = nil) throws -> Any {
        var dev = self.__last_device_backend
        if let d = device {
            dev = d
        }
        guard let qCircuit = self.__quantum_program.circuits[name] else {
            throw QISKitException.missingCompiledQasm
        }
        guard let deviceMap = qCircuit.execution[dev] as? [String:Any] else {
            throw QISKitException.missingCompiledQasm
        }
        guard let circuit = deviceMap["compiled_circuit"] else {
            throw QISKitException.missingCompiledQasm
        }
        return circuit 
    }

    /**
     Print the compiled circuits that are ready to run.
     verbose controls how much is returned.
     */
    func print_execution_list(_ verbose: Bool = false) {
        for (device, jobs) in self.__to_execute {
            print("\(device)")
            for job in jobs {
                if let name = job["name"] as? String {
                    print("  \(name):")
                }
                if let shots = job["shots"] as? Int {
                    print("    shots = \(shots)")
                }
                if let max_credits = job["max_credits"] as? Int {
                    print("    max_credits = \(max_credits)")
                }
                if let seed = job["seed"] as? Double {
                    print("    seed (simulator only) = \(seed)")
                }
                if verbose {
                    print("    compiled_circuit =")
                    print("// *******************************************")
                    if let compiled_circuit = job["compiled_circuit"] as? String {
                        print("\(compiled_circuit)")
                    }
                    print("// *******************************************")
                }
            }
        }
    }


    /**
     Run a program (a pre-compiled quantum program).
     All input for run comes from self.__to_execute
     wait time is how long to check if the job is completed
     timeout is time until the execution stopa
     */
    public func run(_ wait: Int = 5, _ timeout: Int = 60,
                    _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {
        if let (backend,toExecute) = self.__to_execute.first {
            self.run(backend,toExecute,wait,timeout) { (result, error) -> Void in
                if error != nil {
                    // Clear the list of compiled programs to execute
                    self.__to_execute = [:]
                    responseHandler(result,error)
                    return
                }
                self.__to_execute.removeValue(forKey: backend)
                self.run(wait,timeout,responseHandler)
            }
        }
    }

    private func run(_ backend: String,
                     _ toExecute: [[String:Any]],
                     _ wait: Int,
                     _ timeout: Int,
                     _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {

        self.__last_device_backend = backend
        if QuantumProgram.__ONLINE_DEVICES.contains(backend) {
            var last_shots = -1
            var last_max_credits = -1
            var jobs: [[String:Any]] = []
            for job in toExecute {
                guard let compiled_circuit = job["compiled_circuit"] as? String else {
                    continue
                }
                jobs.append(["qasm": compiled_circuit ])
                guard let shots = job["shots"] as? Int else {
                    continue
                }
                guard let max_credits = job["max_credits"] as? Int else {
                    continue
                }
                if last_shots == -1 {
                    last_shots = shots
                }
                else {
                    if last_shots != shots {
                        responseHandler(nil,QISKitException.errorShots)
                        return
                    }
                }
                if last_max_credits == -1 {
                    last_max_credits = max_credits
                }
                else {
                    if last_max_credits != max_credits {
                        responseHandler(nil,QISKitException.errorMaxCredit)
                        return
                    }
                }
            }
            // TODO have an option to print this.
            print("running on backend: \(backend)")
            self.__api.run_job(qasms: jobs, device: backend, shots: last_shots, maxCredits: last_max_credits) { (json, error) -> Void in
                if error != nil {
                    responseHandler(nil,QISKitException.internalError(error: error!))
                    return
                }
                guard let result = json else {
                    responseHandler(nil,QISKitException.missingJobId)
                    return
                }
                guard let jobId = result["id"] as? String else {
                    responseHandler(nil,QISKitException.missingJobId)
                    return
                }
                self.wait_for_job(jobId: jobId, wait: wait, timeout: timeout) { (job_result, error) -> Void in
                    if error != nil {
                        responseHandler(nil,QISKitException.internalError(error: error!))
                        return
                    }
                    do {
                        try self.postRun(backend,toExecute, job_result!)
                    }
                    catch {
                        responseHandler(nil,error as? QISKitException)
                        return
                    }
                    responseHandler(job_result,nil)
                }
            }
        }
        else {
            var jobs: [[String:Any]] = []
            for job in toExecute {
                if let compiled_circuit = job["compiled_circuit"] as? String {
                    jobs.append(["compiled_circuit": compiled_circuit ])
                }
                if let shots = job["shots"] as? Int {
                    jobs.append(["shots": shots ])
                }
                if let seed = job["seed"] as? Int {
                    jobs.append(["seed": seed ])
                }
            }

            // TODO have an option to print this.
            print("running on backend: \(backend)")
            var job_result: [ String: [[String:Any]] ] = [:]
            if backend == "local_qasm_simulator" {
                job_result = QuantumProgram.run_local_qasm_simulator(jobs)
            }
            else {
                if backend == "local_unitary_simulator" {
                    job_result = QuantumProgram.run_local_unitary_simulator(jobs)
                }
                else {
                    responseHandler(nil,QISKitException.errorLocalSimulator)
                    return
                }
            }
            do {
                try self.postRun(backend,toExecute, job_result)
            }
            catch {
                responseHandler(nil,error as? QISKitException)
                return
            }
            responseHandler(job_result,nil)
        }
    }

    private func postRun(_ backend: String,
                         _ toExecute: [[String:Any]],
                         _ job_result: [String: Any]) throws {
        guard let qasms = job_result["qasms"] as? [[String:Any]] else {
            assert(false, "Internal error in QuantumProgram.run(), job_result")
        }
        assert(toExecute.count == qasms.count, "Internal error in QuantumProgram.run(), job_result")

        // Fill data into self.__quantum_program for this backend
        var index = 0
        for job in toExecute {
            guard let name = job["name"] as? String else {
                continue
            }
            guard let qCircuit = self.__quantum_program.circuits[name] else {
                throw QISKitException.missingCircuit
            }
            // We override the results
            var backendMap: [String:Any] = [:]
            if let map = qCircuit.execution[backend] as? [String:Any] {
                backendMap = map
            }
            // TODO: return date, executionId, ...
            for field in ["coupling_map", "basis_gates", "compiled_circuit", "shots", "max_credits", "seed"] {
                backendMap[field] = job[field]
            }
            backendMap["result"] = qasms[index]["result"]
            backendMap["status"] = qasms[index]["status"]
            qCircuit.execution[backend] = backendMap 
            index += 1
        }
    }

    /**
     Wait until all status results are 'COMPLETED'.
     jobids is a list of id strings.
     api is an IBMQuantumExperience object.
     wait is the time to wait between requests, in seconds
     timeout is how long we wait before failing, in seconds
     Returns an list of results that correspond to the jobids
    */
    public func wait_for_job(jobId: String, wait: Int = 5, timeout: Int = 60,
                             _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {
        self.wait_for_job(jobId, wait, timeout, 0, responseHandler)
    }

    private func wait_for_job(_ jobid: String, _ wait: Int, _ timeout: Int, _ elapsed: Int,
                            _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {
        self.__api.get_job(jobId: jobid) { (result, error) -> Void in
            if error != nil {
                responseHandler(nil, QISKitException.internalError(error: error!))
                return
            }
            guard let jobResult = result else {
                responseHandler(nil, QISKitException.missingStatus)
                return
            }
            guard let status = jobResult["status"] as? String else {
                responseHandler(nil, QISKitException.missingStatus)
                return
            }
            print("status = \(status) (\(elapsed) seconds)")
            if status != "RUNNING" {
                if status == "ERROR_CREATING_JOB" || status == "ERROR_RUNNING_JOB" {
                    responseHandler(nil, QISKitException.errorStatus(status: status))
                    return
                }
                responseHandler(jobResult, nil)
                return
            }
            if elapsed >= timeout {
                responseHandler(nil, QISKitException.timeout)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(wait)) {
                self.wait_for_job(jobid, wait, timeout, elapsed + wait, responseHandler)
            }
        }
    }

    /**
     run_local_qasm_simulator, run a program (precompile of quantum circuits).
     jobs is list of dicts {"compiled_circuit": simulator input data, "shots": integer num shots}
     returns
     job_results = {
         "qasms": [
             {
                "result": DATA,
                "status": DATA,
             },
            ...
         ]
     }
     */
    private class func run_local_qasm_simulator(_ jobs: [[String:Any]]) -> [ String: [[String:Any]] ] {
        preconditionFailure("run_local_qasm_simulator not implemented")
        /*var job_results:  [ String: [[String:Any]] ] = ["qasms": []]
        for _ in jobs {
            var one_result: [String:Any] = ["status": "Error" ]
            let qasm_circuit: [String:Any] = [:] //QasmSimulator(job["compiled_circuit"], job["shots"], job["seed"]).run()
            var result: [String:Any] = [:]
            result["data"] = qasm_circuit["data"]!
            one_result["result"] = result 
            one_result["status"] = qasm_circuit["status"]!
            job_results["qasms"]!.append(one_result)
        }
        return job_results*/
    }

    /**
     run_local_unitary_simulator, run a program (precompile of quantum circuits).
     jobs is list of dicts {"compiled_circuit": simulator input data}
     returns
     job_results = {
         "qasms": [
             {
                "result": DATA,
                "status": DATA,
             },
             ...
         ]
     }
     */
    private class func run_local_unitary_simulator(_ jobs: [[String:Any]]) -> [ String: [[String:Any]] ] {
        preconditionFailure("run_local_unitary_simulator not implemented")
       /* var job_results: [ String: [[String:Any]] ] = ["qasms": []]
        for _ in jobs {
            var one_result: [String:Any] = ["status": "Error" ]
            let unitary_circuit: [String:Any] = [:] //UnitarySimulator(job["compiled_circuit"]).run()
            var result: [String:Any] = [:]
            result["data"] = unitary_circuit["data"]!
            one_result["result"] = result 
            one_result["status"] = unitary_circuit["status"]!
            job_results["qasms"]!.append(one_result)
        }
        return job_results*/
    }

    /**
     Execute, compile, and run a program (array of quantum circuits).
     program is a list of quantum_circuits
     api is the api for the device
     device is a string for real or simulator
     shots is the number of shots
     max_credits is the maximum credits for the experiments
     basis_gates are the base gates, which by default are: u1,u2,u3,cx,id
     */
    public func execute(_ name_of_circuits: [String],
                        device: String = "local_qasm_simulator",
                        shots: Int = 1024,
                        max_credits: Int = 3,
                        wait: Int = 5,
                        timeout: Int = 60,
                        basis_gates: String? = nil,
                        coupling_map: [Int:[Int]]? = nil,
                        seed: Double? = nil,
                        _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {
        do {
            try self.compile(name_of_circuits,
                             device: device,
                             shots: shots,
                             max_credits: max_credits,
                             basis_gates: basis_gates,
                             coupling_map: coupling_map,
                             seed: seed)
            self.run(wait, timeout,responseHandler)
        } catch {
            responseHandler(nil,error as? QISKitException)
        }
    }

    /**
     Get the dict of labels and counts from the output of get_job.
     name is the name or index of one circuit."""
     */
    public func get_counts(_ name: String , _ device: String? = nil) throws -> Int {
        var dev: String = self.__last_device_backend
        if let d = device {
            dev = d
        }
        guard let qCircuit = self.__quantum_program.circuits[name] else {
            throw QISKitException.missingCircuit
        }
        guard let deviceMap = qCircuit.execution[dev] as? [String:Any] else {
            throw QISKitException.missingCircuit
        }
        guard let result = deviceMap["result"] as? [String:Any] else {
            throw QISKitException.missingCircuit
        }
        guard let data = result["data"] as? [String:Any] else {
            throw QISKitException.missingCircuit
        }
        guard let counts = data["counts"] as? Int else {
            throw QISKitException.missingCircuit
        }
        return counts
    }
}
