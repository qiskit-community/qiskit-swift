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
/**
 Elements that are not python identifiers or string constants are denoted
 by "--description (type)--". For example, a circuit's name is denoted by
 "--circuit name (string)--" and might have the value "teleport".

 __quantum_program = {
 "circuits": {
     --circuit name (string)--: {
         "circuit": --circuit object (TBD)--,
         "execution": {  #### FILLED IN AFTER RUN -- JAY WANTS THIS MOVED DOWN ONE LAYER ####
             --backend name (string)--: {
                 "coupling_map": --adjacency list (dict)--,
                 "basis_gates": --comma separated gate names (string)--,
                 "compiled_circuit": --compiled quantum circuit (currently QASM text)--,
                 "shots": --shots (int)--,
                 "max_credits": --credits (int)--,
                 "result": {
                     "data": {  #### DATA CAN BE A DIFFERENT DICTIONARY FOR EACH BACKEND ####
                        "counts": {’00000’: XXXX, ’00001’: XXXXX},
                        "time"  : xx.xxxxxxxx
                     },
                     "date"  : "2017−05−09Txx:xx:xx.xxxZ",
                     "status": --status (string)--
                 }
             },
         }
     }
 }

 __to_execute = {
     --backend name (string)--: [
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
/**
 # -- FUTURE IMPROVEMENTS --
 # TODO: for status results choose ALL_CAPS, or This but be consistent
 # TODO: coupling_map, basis_gates will move to compiled_circuit object
 # TODO: compiled_circuit is currently QASM text. In the future we will
 #       make a method in the QuantumCircuit object that makes an object
 #       to be passed to the runner and this will live in compiled_circuit.
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

    private static let __LOCAL_BACKENDS: Set<String> = ["local_unitary_simulator", "local_qasm_simulator", "local_qasm_cpp_simulator"]

    public let name: String
    private var config: Qconfig
    private var __quantum_program: QProgram
    private var __api: IBMQuantumExperience
    private var __api_config: APIConfig = APIConfig()
    private var __quantum_registers: [String: QuantumRegister] = [:]
    private var __classical_registers: [String: ClassicalRegister] = [:]
    private var __init_circuit: QuantumCircuit? = nil
    private var __last_backend: String = ""
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

    public func get_api() -> IBMQuantumExperience {
        return self.__api
    }


    // TODO: we would like API to use "backend"s instead of "device"s
    public func online_backends(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        self.__api.available_devices() { (backends,error) in
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

    public func available_backends(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        self.online_backends() { (backends,error) in
            if error != nil {
                responseHandler([],error)
                return
            }
            var ret = backends
            ret.formUnion(QuantumProgram.__LOCAL_BACKENDS)
            responseHandler(ret,nil)
        }
    }

    /**
     Return the online backend status via QX API call or by local
     backend is the name of the local or online simulator or experiment
    */
    public func get_backend_status(_ backend: String,
                                  responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.online_backends() { (backends,error) in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            if backends.contains(backend) {
                self.__api.device_status(backend,responseHandler: responseHandler)
                return
            }
            if QuantumProgram.__LOCAL_BACKENDS.contains(backend) {
                responseHandler(["available" : true],nil)
                return
            }
            responseHandler(nil,IBMQuantumExperienceError.errorDevice(device: backend))
        }
    }

    /**
     Return the configuration of the backend
     */
    public func get_backend_configuration(_ backend: String,
                                   responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.__api.available_devices() { (backends,error) in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            for test_backend in backends {
                if let name = test_backend["name"] as? String {
                    if name == backend {
                        responseHandler(test_backend,nil)
                        return
                    }
                }
            }
            for test_backend in LocalSimulator.local_configuration {
                if let name = test_backend["name"] as? String {
                    if name == backend {
                        responseHandler(test_backend,nil)
                        return
                    }
                }
            }
            responseHandler(nil,IBMQuantumExperienceError.errorDevice(device: backend))
        }
    }

    /**
     Return the online backend calibrations via QX API call
     backend is the name of the experiment
     */
    public func get_backend_calibration(_ backend: String,
                                       responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.online_backends() { (backends,error) in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            if backends.contains(backend) {
                // TODO: we would like API to use "backend" instead of "device"
                self.__api.device_calibration(backend,responseHandler: responseHandler)
                return
            }
            if QuantumProgram.__LOCAL_BACKENDS.contains(backend) {
                responseHandler(["calibrations" : "NA"],nil)
                return
            }
            responseHandler(nil,IBMQuantumExperienceError.errorDevice(device: backend))
        }
    }

    /**
     Return the online backend parameters via QX API call
     backend is the name of the experiment
     */
    public func get_backend_parameters(_ backend: String,
                                        responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.online_backends() { (backends,error) in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            if backends.contains(backend) {
                // TODO: we would like API to use "backend" instead of "device"
                self.__api.device_parameters(backend,responseHandler: responseHandler)
                return
            }
            if QuantumProgram.__LOCAL_BACKENDS.contains(backend) {
                responseHandler(["parameters" : "NA"],nil)
                return
            }
            responseHandler(nil,IBMQuantumExperienceError.errorDevice(device: backend))
        }
    }

    /**
     Create a new set of Quantum Register
     */
    @discardableResult
    public func create_quantum_registers(_ name: String, _ size: Int) throws -> QuantumRegister {
        try self.__quantum_registers[name] = QuantumRegister(name, size)
        return self.__quantum_registers[name]!
    }

    /**
     Create a new set of Quantum Registers based in a array of that
     */
    public func create_quantum_registers_group(_ registers_array:[Any]) throws -> [QuantumRegister] {
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
    @discardableResult
    public func  create_classical_registers(_ name: String, _ size: Int) throws -> ClassicalRegister {
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
    @discardableResult
    public func create_circuit(_ name: String,
                               _ qregisters: [QuantumRegister] = [],
                               _ cregisters: [ClassicalRegister] = [],
                               _ circuit_object: QuantumCircuit = QuantumCircuit()) throws -> QuantumCircuit {
        self.__quantum_program.circuits[name] = QCircuit(name, circuit_object)

        for register in qregisters {
            if self.__quantum_registers[register.name] == nil {
                throw QISKitException.regnotexists(name: register.name)
            }
            try self.__quantum_program.circuits[name]!.circuit.add([register])
        }
        for register in cregisters {
            if self.__classical_registers[register.name] == nil {
                throw QISKitException.regnotexists(name: register.name)
            }
            try self.__quantum_program.circuits[name]!.circuit.add([register])
        }
        return self.__quantum_program.circuits[name]!.circuit
    }

    /**
     Create a new Quantum Circuit into the Quantum Program
     name is a string, the name of the circuit
     qregisters is a Array of Quantum Registers names
     cregisters is a Array of Classical Registers names
     */
    @discardableResult
    public func create_circuit(_ name: String,
                               _ qregisters: [String] = [],
                               _ cregisters: [String] = [],
                               _ circuit_object: QuantumCircuit = QuantumCircuit()) throws -> QuantumCircuit {
        self.__quantum_program.circuits[name] = QCircuit(name, circuit_object)

        for regName in qregisters {
            guard let register = self.__quantum_registers[regName] else {
                throw QISKitException.regnotexists(name: regName)
            }
            try self.__quantum_program.circuits[name]!.circuit.add([register])
        }
        for regName in cregisters {
            guard let register = self.__classical_registers[regName] else {
                throw QISKitException.regnotexists(name: regName)
            }
            try self.__quantum_program.circuits[name]!.circuit.add([register])
        }
        return self.__quantum_program.circuits[name]!.circuit
    }

    /**
     Return a Quantum Register by nam
     */
    @discardableResult
    public func get_quantum_registers(_ name: String) -> QuantumRegister? {
        return self.__quantum_registers[name]
    }

    /**
     Return a Classical Register by name
     */
    @discardableResult
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
     Return all circuit names
     */
    public func get_circuit_names() -> [String] {
        return Array<String>(self.__quantum_program.circuits.keys)
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
    /*
    func load_qasm(name: String = "", qasm_file: String? = nil, basis: String? = nil) throws {
        guard let file = qasm_file else {
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
        let circuit_object = try Qasm(filename:file).parse() // Node (AST)

        //TODO: add method to convert to QuantumCircuit object from Node
        //self.__quantum_program.circuits[n] = QCircuit(n, circuit_object)
    }
    */

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
                    self.__init_circuit = try self.create_circuit(name,quantumr,classicalr)
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
            try self.create_circuit(name,[qReg!],[cReg!])
        }
    }

    /**
     Add a new circuit based in a Object representation.
     name is the name or index of one circuit.
     */
    @discardableResult
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
        let unrolled_circuit = Unroller(try Qasm(data: circuitQasm).parse(),
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
                 backend: String = "local_qasm_simulator",
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
                //print("qasm compiled: \(qasm_compiled)")
                //print("pre-mapping properties: \(try dag_unrolled.property_summary())")
                // Insert swap gates
                let coupling = try Coupling(coupling_map)
                var (dag_unrolled, _) = try Mapping.swap_mapper(dag_unrolled, coupling)
                //print("layout: \(final_layout)")
                // Expand swaps
                (qasm_compiled, dag_unrolled) = try self.unroller_code(try dag_unrolled.qasm())
                // Change cx directions
                dag_unrolled = try Mapping.direction_mapper(dag_unrolled,coupling)
                // Simplify cx gates
                try Mapping.cx_cancellation(dag_unrolled)
                // Simplify single qubit gates
                dag_unrolled = try Mapping.optimize_1q_gates(dag_unrolled)
                qasm_compiled = try dag_unrolled.qasm(qeflag: true)
                //print("post-mapping properties: \(try dag_unrolled.property_summary())")
            }
            // TODO: add timestamp, compilation
            var jobs: [[String:Any]] = []
            if let arr = self.__to_execute[backend] {
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
            self.__to_execute[backend] = jobs
        }
    }

    /**
     Get the compiled qasm for the named circuit and device.
     If device is None, it defaults to the last device.
    */
    public func get_compiled_qasm(_ name: String, _ backend: String? = nil) throws -> Any {
        var dev = self.__last_backend
        if let d = backend {
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
    public func print_execution_list(_ verbose: Bool = false) {
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
    public func run(_ wait: Int = 5, _ timeout: Int = 60, _ silent: Bool = false,
                    _ responseHandler: @escaping ((_:QISKitException?) -> Void)) {
        self.online_backends() { (onlineBackends,error) in
            if error != nil {
                responseHandler(QISKitException.internalError(error:error!))
                return
            }
            if let (backend,toExecute) = self.__to_execute.first {
                self.run(backend,onlineBackends,toExecute,wait,timeout,silent) { (result, error) -> Void in
                    if error != nil {
                        // Clear the list of compiled programs to execute
                        self.__to_execute = [:]
                        responseHandler(error)
                        return
                    }
                    self.__to_execute.removeValue(forKey: backend)
                    self.run(wait,timeout,silent,responseHandler)
                }
                return
            }
            responseHandler(nil)
        }
    }

    private func run(_ backend: String,
                     _ onlineBackends: Set<String>,
                     _ toExecute: [[String:Any]],
                     _ wait: Int,
                     _ timeout: Int,
                     _ silent: Bool,
                     _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {

        self.__last_backend = backend
        if onlineBackends.contains(backend) {
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
            if !silent {
                print("running on backend: \(backend)")
            }
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
            do {
                var jobs: [[String:Any]] = []
                for job in toExecute {
                    // this will get pushed into the compiler when online supports json
                    guard let compiled_circuit = job["compiled_circuit"] as? String else {
                        continue
                    }
                    let basis_gates: [String] = []  // unroll to base gates
                    let unroller = Unroller(try Qasm(data: compiled_circuit).parse(),JsonBackend(basis_gates))
                    try unroller.execute()
                    let json_circuit = (unroller.backend as! JsonBackend).circuit
                    // converts qasm circuit to json circuit
                    var job: [String:Any] = [:]
                    job["compiled_circuit"] = json_circuit
                    if let shots = job["shots"] as? Int {
                        job["shots"] = shots
                    }
                    if let seed = job["seed"] as? Int {
                        job["seed"] = seed
                    }
                    jobs.append(job)

                }
                if !silent {
                    print("running on backend: \(backend)")
                }

                var job_result: [ String: [[String:Any]] ] = [:]
                if QuantumProgram.__LOCAL_BACKENDS.contains(backend) {
                    job_result = try QuantumProgram.run_local_simulator(backend,jobs)
                }
                else {
                    responseHandler(nil,QISKitException.errorLocalSimulator)
                    return
                }
                try self.postRun(backend,toExecute, job_result)
                responseHandler(job_result,nil)
            }
            catch {
                responseHandler(nil,error as? QISKitException)
                return
            }
        }
    }

    private func postRun(_ backend: String,
                         _ toExecute: [[String:Any]],
                         _ job_result: [String: Any]) throws {
        guard let qasms = job_result["qasms"] as? [[String:Any]] else {
            assert(false, "Internal error in QuantumProgram.run(), job_result")
            return
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
    public func wait_for_job(jobId: String, wait: Int = 5, timeout: Int = 60,_ silent: Bool = false,
                             _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitException?) -> Void)) {
        self.wait_for_job(jobId, wait, timeout, silent, 0, responseHandler)
    }

    private func wait_for_job(_ jobid: String, _ wait: Int, _ timeout: Int, _ silent: Bool, _ elapsed: Int,
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
            if !silent {
                print("status = \(status) (\(elapsed) seconds)")
            }
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
                self.wait_for_job(jobid, wait, timeout, silent, elapsed + wait, responseHandler)
            }
        }
    }

    /**
     Run a program of compiled quantum circuits on the local machine.

     Args:
         backend (str): the name of the local simulator to run
         jobs: list of dicts {"compiled_circuit": simulator input data, "shots": integer num shots}

         Returns:
         Dictionary of form,
         job_results = [
             "qasms": [
                 [
                    "result": DATA,
                    "status": DATA,
                 ],
                 ...
             ]
         ]
     */
    private class func run_local_simulator(_ backend: String, _ jobs: [[String:Any]]) throws -> [String: [[String:Any]] ] {
        var job_results: [[String:Any]] = []
        for job in jobs {
            let local_simulator = LocalSimulator(backend, job)
            job_results.append(try local_simulator.run())
        }
        return ["qasms" : job_results ]
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
                        backend: String = "local_qasm_simulator",
                        shots: Int = 1024,
                        max_credits: Int = 3,
                        wait: Int = 5,
                        timeout: Int = 60,
                        silent: Bool = false,
                        basis_gates: String? = nil,
                        coupling_map: [Int:[Int]]? = nil,
                        seed: Double? = nil,
                        _ responseHandler: @escaping ((_:QISKitException?) -> Void)) {
        do {
            try self.compile(name_of_circuits,
                             backend: backend,
                             shots: shots,
                             max_credits: max_credits,
                             basis_gates: basis_gates,
                             coupling_map: coupling_map,
                             seed: seed)
            self.run(wait,timeout,silent,responseHandler)
        } catch {
            if let err = error as? QISKitException {
                responseHandler(err)
            }
            responseHandler(QISKitException.internalError(error: error))
        }
    }

    /**
     Method to process the data
     */
    public func get_result(_ name: String , backend: String? = nil) throws -> [String:Any] {
        var dev: String = self.__last_backend
        if let d = backend {
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
        return result
    }

    /**
     Get the dict of labels and counts from the output of get_job.
     results are the list of results
     name is the name or index of one circuit
     */
    public func get_data(_ name: String , backend: String? = nil) throws -> [String:Any] {
        let result = try self.get_result(name,backend: backend)
        guard let data = result["data"] as? [String:Any] else {
            throw QISKitException.missingCircuit
        }
        return data
    }

    /**
     Get the dict of labels and counts from the output of get_job.
     name is the name or index of one circuit.
     */
    public func get_counts(_ name: String , backend: String? = nil) throws -> [String:Int] {
        let data = try self.get_data(name,backend: backend)
        guard let counts = data["counts"] as? [String:Int] else {
            throw QISKitException.missingCircuit
        }
        return counts
    }

    /**
     Compute the mean value of an diagonal observable.

     Takes in an observable in dictionary format and then
     calculates the sum_i value(i) P(i) where value(i) is the value of
     the observable for state i.

     returns a double
     */
    public func average_data(_ name: String, _ observable: [String:Double]) throws -> Double {
        let counts = try self.get_counts(name)
        var tot: Double = 0
        for (_,count) in counts {
            tot += Double(count)
        }
        var temp: Double = 0.0
        for (key,count) in counts {
            if let value = observable[key] {
                temp += Double(count) * value / tot
            }
        }
        return temp
    }
}
