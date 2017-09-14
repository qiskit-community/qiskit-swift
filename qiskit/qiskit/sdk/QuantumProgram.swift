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
Quantum Program Class.

Class internal properties.

    Elements that are not python identifiers or string constants are denoted
    by "--description (type)--". For example, a circuit's name is denoted by
    "--circuit name (string)--" and might have the value "teleport".

    Internal::

        __quantum_registers (list[dic]): An dictionary of quantum registers
            used in the quantum program.
            __quantum_registers =
                {
                    --register name (string)--: QuantumRegistor,
                }
        __classical_registers (list[dic]): An ordered list of classical registers
            used in the quantum program.
            __classical_registers =
                {
                    --register name (string)--: ClassicalRegistor,
                }
        __quantum_program (dic): An dictionary of quantum circuits
            __quantum_program =
                {
                    --circuit name (string)--:  --circuit object --,
                }
        __init_circuit (obj): A quantum circuit object for the initial quantum
            circuit
        __ONLINE_BACKENDS (list[str]): A list of online backends
        __LOCAL_BACKENDS (list[str]): A list of local backends
 */

/**
# -- FUTURE IMPROVEMENTS --
# TODO: for status results make ALL_CAPS (check) or some unified method
# TODO: Jay: coupling_map, basis_gates will move into a config object
*/

public final class QCircuit {
    public let name: String
    public let circuit: QuantumCircuit
    public private(set) var execution: [String:Any] = [:]

    init(_ name: String, _ circuit: QuantumCircuit) {
        self.name = name
        self.circuit = circuit
    }
}

public final class QProgram {
    public private(set) var circuits: [String: QCircuit] = [:]

    func setCircuit(_ name: String, _ circuit: QCircuit) {
        self.circuits[name] = circuit
    }
}

public final class APIConfig {
    public let token: String
    public let url: URL

    init(_ token: String = "None" , _ url: String = Qconfig.BASEURL) throws {
        guard let u = URL(string: url) else {
            throw IBMQuantumExperienceError.invalidURL(url: url)
        }
        self.token = token
        self.url = u
    }
}

public final class QuantumProgram {

    private var __LOCAL_BACKENDS: Set<String> = Set<String>()

    /**
     only exists once you set the api to use the online backends
     */
    private var __api: IBMQuantumExperience
    private var __api_config: APIConfig

    private var __quantum_registers: [String: QuantumRegister] = [:]
    private var __classical_registers: [String: ClassicalRegister] = [:]
    /**
     stores all the quantum programs
     */
    private var __quantum_program: QProgram
    /**
     stores the intial quantum circuit of the program
     */
    private var __init_circuit: QuantumCircuit? = nil

    private var config: Qconfig

    static private func convert(_ name: String) throws -> String {
        do {
            let first_cap_re = try NSRegularExpression(pattern:"(.)([A-Z][a-z]+)")
            let s1 = first_cap_re.stringByReplacingMatches(in: name,
                                                           options: [],
                                                           range:  NSMakeRange(0, name.characters.count),
                                                           withTemplate: "\\1_\\2")
            let all_cap_re = try NSRegularExpression(pattern:"([a-z0-9])([A-Z])")
            return all_cap_re.stringByReplacingMatches(in: s1,
                                                       options: [],
                                                       range: NSMakeRange(0, s1.characters.count),
                                                       withTemplate: "\\1_\\2").lowercased()
        } catch {
            throw QISKitError.internalError(error: error)
        }
    }

    public init(specs: [String:Any]? = nil) throws {
        self.__api_config = try APIConfig()
        self.config  = try Qconfig()
        self.__quantum_program = QProgram()
        self.__api = try IBMQuantumExperience("",self.config)
        self.__LOCAL_BACKENDS = self.local_backends()
        if let s = specs {
            try self.__init_specs(s)
        }
    }

    /**
     Populate the Quantum Program Object with initial Specs
     
     Args:
         specs (dict):
             Q_SPECS = {
                 "circuits": [{
                     "name": "Circuit",
                     "quantum_registers": [{
                        "name": "qr",
                        "size": 4
                     }],
                     "classical_registers": [{
                        "name": "cr",
                        "size": 4
                     }]
                 }],
         verbose (bool): controls how information is returned.

     Returns:
        Sets up a quantum circuit.
     */
    private func __init_specs(_ specs:[String: Any], verbose: Bool=false) throws {
        var quantumr:[QuantumRegister] = []
        var classicalr:[ClassicalRegister] = []
        if let circuits = specs["circuits"] as? [Any] {
            for circ in circuits {
                if let circuit = circ as? [String:Any] {
                    if let qregs = circuit["quantum_registers"] as? [[String:Any]] {
                        quantumr = try self.create_quantum_registers(qregs)
                    }
                    if let cregs = circuit["classical_registers"] as? [[String:Any]] {
                        classicalr = try self.create_classical_registers(cregs)
                    }
                    var name: String = "name"
                    if let n = circuit["name"] as? String {
                        name = n
                    }
                    try self.create_circuit(name,quantumr,classicalr)
                }
            }
            // TODO: Jay: I think we should return function handles for the registers
            // and circuit. So that we dont need to get them after we create them
            // with get_quantum_register etc
        }
    }

    /**
     Create a new Quantum Register.

     Args:
        name (str): the name of the quantum register
        size (int): the size of the quantum register
        verbose (bool): controls how information is returned.

     Returns:
        internal reference to a quantum register in __quantum_registers
     */
    @discardableResult
    public func create_quantum_register(_ name: String, _ size: Int, verbose: Bool=false) throws -> QuantumRegister {
        if let register = self.__quantum_registers[name] {
            if size != register.size {
                throw QISKitError.registerSize
            }
            if verbose {
                print(">> quantum_register exists: \(name) \(size)")
            }
        }
        else {
            if verbose {
                print(">> new quantum_register created: \(name) \(size)")
            }
            try self.__quantum_registers[name] = QuantumRegister(name, size)
        }
        return self.__quantum_registers[name]!
    }

    /**
     Create a new set of Quantum Registers based on a array of them.

     Args:
        register_array (list[dict]): An array of quantum registers in
        dictionay format::

             "quantum_registers": [
                 {
                    "name": "qr",
                    "size": 4
                 },
                 ...
             ]
        Returns:
            Array of quantum registers objects
     */
    @discardableResult
    public func create_quantum_registers(_ register_array: [[String: Any]]) throws -> [QuantumRegister] {
        var new_registers: [QuantumRegister] = []
        for register in register_array {
            guard let name = register["name"] as? String else {
                continue
            }
            guard let size = register["size"] as? Int else {
                continue
            }
            new_registers.append(try self.create_quantum_register(name,size))
        }
        return new_registers
    }

    /**
     Create a new Classical Register.

     Args:
        name (str): the name of the Classical register
        size (int): the size of the Classical register
        verbose (bool): controls how information is returned.

     Returns:
        internal reference to a Classical register in __classical_registers
     */
    @discardableResult
    public func create_classical_register(_ name: String, _ size: Int, verbose: Bool=false) throws -> ClassicalRegister {
        if let register = self.__classical_registers[name] {
            if size != register.size {
                throw QISKitError.registerSize
            }
            if verbose {
                print(">> classical register exists: \(name) \(size)")
            }
        }
        else {
            if verbose {
                print(">> new classical register created: \(name) \(size)")
            }
            try self.__classical_registers[name] = ClassicalRegister(name, size)
        }
        return self.__classical_registers[name]!
    }

    /**
     Create a new set of Classical Registers based on a array of them.

     Args:
        register_array (list[dict]): An array of classical registers in
        dictionay format::

             "quantum_registers": [
                 {
                 "name": "qr",
                 "size": 4
                 },
                 ...
             ]
        Returns:
        Array of classical registers objects
     */
    @discardableResult
    public func create_classical_registers(_ register_array: [[String: Any]]) throws -> [ClassicalRegister] {
        var new_registers: [ClassicalRegister] = []
        for register in register_array {
            guard let name = register["name"] as? String else {
                continue
            }
            guard let size = register["size"] as? Int else {
                continue
            }
            new_registers.append(try self.create_classical_register(name,size))
        }
        return new_registers
    }

    /**
     Create a empty Quantum Circuit in the Quantum Program.

     Args:
        name (str): the name of the circuit
        qregisters list(object): is an Array of Quantum Registers by object reference
        cregisters list(object): is an Array of Classical Registers by
        object reference

     Returns:
        A quantum circuit is created and added to the Quantum Program
    */
    @discardableResult
    public func create_circuit(_ name: String,
                               _ qregisters: [QuantumRegister] = [],
                               _ cregisters: [ClassicalRegister] = []) throws -> QuantumCircuit {
        let quantum_circuit = QuantumCircuit()
        if self.__init_circuit == nil {
            self.__init_circuit = quantum_circuit
        }
        try quantum_circuit.add(qregisters)
        try quantum_circuit.add(cregisters)
        try self.add_circuit(name, quantum_circuit)
        return self.__quantum_program.circuits[name]!.circuit
    }

    /**
     Add a new circuit based on an Object representation.

     Args:
        name (str): the name of the circuit to add.
        quantum_circuit: a quantum circuit to add to the program-name
     Returns:
        the quantum circuit is added to the object.
     */
    @discardableResult
    public func add_circuit(_ name: String, _ quantum_circuit: QuantumCircuit) throws -> QuantumCircuit {
        for (qname, qreg) in quantum_circuit.get_qregs() {
            try self.create_quantum_register(qname, qreg.size)
        }
        for (cname, creg) in quantum_circuit.get_cregs() {
            try self.create_classical_register(cname, creg.size)
        }
        self.__quantum_program.setCircuit(name,QCircuit(name, quantum_circuit))
        return quantum_circuit
    }

    /**
     Load qasm file into the quantum program.

     Args:
        qasm_file (str): a string for the filename including its location.
        name (str or None, optional): the name of the quantum circuit after
            loading qasm text into it. If no name is give the name is of
            the text file.
        verbose (bool, optional): controls how information is returned.
     Retuns:
        Adds a quantum circuit with the gates given in the qasm file to the
        quantum program and returns the name to be used to get this circuit
     */
     func load_qasm(qasm_file: String, name: String? = nil, verbose: Bool = false) throws -> String {
        var n: String = ""
        if name != nil {
            n = name!
        }
        else {
            n = (qasm_file as NSString).lastPathComponent
        }
        return try self.load_qasm(Qasm(filename:qasm_file),n,verbose)
     }

    /**
     Load qasm string in the quantum program.
     
     Args:
        qasm_string (str): a string for the file name.
        name (str): the name of the quantum circuit after loading qasm
            text into it. If no name is give the name is of the text file.
        verbose (bool): controls how information is returned.
     Retuns:
        Adds a quantum circuit with the gates given in the qasm string to the
        quantum program.
     */
    public func load_qasm_text(qasm_string: String, name: String? = nil, verbose: Bool = false) throws -> String {
        var n: String = ""
        if name != nil {
            n = name!
        }
        else {
            n = String.randomAlphanumeric(length: 10)
        }
        return try self.load_qasm(Qasm(data:qasm_string),n,verbose)
    }

    private func load_qasm(_ qasm: Qasm, _ name: String, _ verbose: Bool) throws -> String {
        let node_circuit = try qasm.parse()
        if verbose {
            print("circuit name: \(name)")
            print("******************************")
            print(node_circuit.qasm(15))
        }

        // current method to turn it a DAG quantum circuit.
        let basis_gates = "u1,u2,u3,cx,id"  // QE target basis
        let unrolled_circuit = Unroller(node_circuit, CircuitBackend(basis_gates.components(separatedBy:",")))
        let circuit_unrolled = try unrolled_circuit.execute() as! QuantumCircuit
        try self.add_circuit(name, circuit_unrolled)
        return name
    }

    /**
     Return a Quantum Register by name.
     Args:
     name (str): the name of the register
     Returns:
     The quantum registers with this name
     */
    @discardableResult
    public func get_quantum_register(_ name: String) throws -> QuantumRegister {
        guard let reg = self.__quantum_registers[name] else {
            throw QISKitError.regNotExists(name: name)
        }
        return reg
    }

    /**
     Return a Classical Register by name.
     Args:
     name (str): the name of the register
     Returns:
     The classical registers with this name
     */
    @discardableResult
    public func get_classical_register(_ name: String) throws -> ClassicalRegister {
        guard let reg = self.__classical_registers[name] else {
            throw QISKitError.regNotExists(name: name)
        }
        return reg
    }

    /**
     Return all the names of the quantum Registers.
     */
    public func get_quantum_register_names() -> [String] {
        return Array(self.__quantum_registers.keys)
    }

    /**
     Return all the names of the classical Registers.
     */
    public func get_classical_register_names() -> [String] {
        return Array(self.__classical_registers.keys)
    }

    /**
     Return a Circuit Object by name
     Args:
        name (str): the name of the quantum circuit
     Returns:
        The quantum circuit with this name
     */
    @discardableResult
    public func get_circuit(_ name: String) throws -> QuantumCircuit {
        guard let qCircuit =  self.__quantum_program.circuits[name] else {
            throw QISKitError.missingCircuit
        }
        return qCircuit.circuit
    }

    /**
     Return all the names of the quantum circuits.
     */
    public func get_circuit_names() -> [String] {
        return Array(self.__quantum_program.circuits.keys)
    }

    /**
     Get qasm format of circuit by name.
     Args:
        name (str): name of the circuit
     Returns:
        The quantum circuit in qasm format
     */
    public func get_qasm(_ name: String) throws -> String {
        let quantum_circuit = try self.get_circuit(name)
        return quantum_circuit.qasm()
    }

    /**
     Get qasm format of circuit by list of names.
     Args:
        list_circuit_name (list[str]): names of the circuit
     Returns:
        List of quantum circuit in qasm format
     */
    public func get_qasms(_ list_circuit_name: [String]) throws -> [String] {
        var qasm_source: [String] = []
        for name in list_circuit_name {
            qasm_source.append(try self.get_qasm(name))
        }
        return qasm_source
    }

    /**
     Return the initialization Circuit.
     */
    public func get_initial_circuit() -> QuantumCircuit? {
        return self.__init_circuit
    }

    /**
     Setup the API.
        Args:
            Token (str): The token used to register on the online backend such
                as the quantum experience.
            URL (str): The url used for online backend such as the quantum
                experience.
            Verify (Boolean): If False, ignores SSL certificates errors.
        Returns:
            Nothing but fills __api, and __api_config
     */
    public func set_api(token: String, url: String, verify: Bool = true) throws {
        self.__api_config = try APIConfig(token,url)
        self.__api = try IBMQuantumExperience(self.__api_config.token, try Qconfig(url: self.__api_config.url.absoluteString),verify)
    }

    /**
     Return the program specs
     */
    public func get_api_config() -> APIConfig {
        return self.__api_config
    }

    /**
     Returns a function handle to the API
     */
    public func get_api() -> IBMQuantumExperience {
        return self.__api
    }

    /**
     Save Quantum Program in a Json file.
     Args:
        file_name (str): file name and path.
        beauty (boolean): save the text with indent to make it readable.
     Returns:
        The dictionary with the result of the operation
     */
    public func save(_ file_name: String, _ beauty: Bool = false) throws -> [String:[String:Any]] {
        do {
            let elements_to_save = self.__quantum_program.circuits
            var elements_saved: [String:[String:Any]] = [:]

            for (name,value) in elements_to_save {
                elements_saved[name] = [:]
                elements_saved[name]!["qasm"] = value.circuit.qasm()
            }

            let options = beauty ? JSONSerialization.WritingOptions.prettyPrinted : []

            let data = try JSONSerialization.data(withJSONObject: elements_saved, options: options)
            let contents = String(data: data, encoding: .utf8)
            try contents?.write(toFile: file_name, atomically: true, encoding: .utf8)
            return elements_saved
        } catch {
            throw QISKitError.internalError(error: error)
        }
    }

    /**
     Load Quantum Program Json file into the Quantum Program object.
     Args:
        file_name (str): file name and path.
     Returns:
        The result of the operation
    */
    public func load(_ file_name: String) throws -> QProgram {
        let elements_loaded = QProgram()
        do {
            let file = FileHandle(forReadingAtPath: file_name)
            let data = file!.readDataToEndOfFile()
            let jsonAny = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

            if let dict = jsonAny as? [String:[String:Any]] {
                for (name,value) in dict {
                    if let qasm_string = value["qasm"] as? String {
                        let qasm = Qasm(data:qasm_string)
                        let node_circuit = try qasm.parse()
                        // current method to turn it a DAG quantum circuit.
                        let basis_gates = "u1,u2,u3,cx,id"  // QE target basis
                        let unrolled_circuit = Unroller(node_circuit, CircuitBackend(basis_gates.components(separatedBy:",")))
                        let circuit_unrolled = try unrolled_circuit.execute() as! QuantumCircuit
                        elements_loaded.setCircuit(name,QCircuit(name,circuit_unrolled))
                    }
                }
            }
            self.__quantum_program = elements_loaded
            return self.__quantum_program
        } catch {
            throw QISKitError.internalError(error: error)
        }
    }

    /**
     All the backends that are seen by QISKIT.
     */
    public func available_backends(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        self.online_backends() { (backends,error) in
            if error != nil {
                responseHandler([],error)
                return
            }
            var ret = backends
            ret.formUnion(self.local_backends())
            responseHandler(ret,nil)
        }
    }

    /**
     Get the local backends.
     */
    public func local_backends() -> Set<String> {
        return LocalSimulator.local_backends
    }

    /**
     Queries network API if it exists.

     Returns
     -------
     List of online backends if the online api has been set or an empty
     list of it has not been set.
    */
    public func online_backends(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        self.__api.available_backends() { (backends,error) in
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

    /**
     Gets online simulators via QX API calls.

     Returns
     -------
     List of online simulator names.
     */
    public func online_simulators(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        self.__api.available_backends() { (backends,error) in
            if error != nil {
                responseHandler([],error)
                return
            }
            var ret: Set<String> = []
            for backend in backends {
                guard let simulator = backend["simulator"] as? Bool else {
                    continue
                }
                if simulator {
                    if let name = backend["name"] as? String {
                        ret.update(with: name)
                    }
                }
            }
            responseHandler(ret,nil)
        }
    }

    /**
     Gets online devices via QX API calls
     */
    public func online_devices(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) {
        self.__api.available_backends() { (backends,error) in
            if error != nil {
                responseHandler([],error)
                return
            }
            var ret: Set<String> = []
            for backend in backends {
                guard let simulator = backend["simulator"] as? Bool else {
                    continue
                }
                if !simulator {
                    if let name = backend["name"] as? String {
                        ret.update(with: name)
                    }
                }
            }
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
                self.__api.backend_status(backend,responseHandler: responseHandler)
                return
            }
            if self.local_backends().contains(backend) {
                responseHandler(["available" : true],nil)
                return
            }
            responseHandler(nil,IBMQuantumExperienceError.errorBackend(backend: backend))
        }
    }

    /**
     Return the configuration of the backend
     */
    public func get_backend_configuration(_ backend: String, _ list_format: Bool = false,
                                   responseHandler: @escaping ((_:[String:Any]?, _:IBMQuantumExperienceError?) -> Void)) {
        self.__api.available_backends() { (backends,error) in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            do {
                let set = Set<String>(["id", "serial_number", "topology_id", "status", "coupling_map"])
                var configuration_edit: [String:Any] = [:]
                for configuration in backends {
                    if let name = configuration["name"] as? String {
                        if name == backend {
                            for (key,value) in configuration {
                                let new_key = try QuantumProgram.convert(key)
                                // TODO: removed these from the API code
                                if !set.contains(new_key) {
                                    configuration_edit[new_key] = value
                                }
                                if new_key == "coupling_map" {
                                    var conf: String = ""
                                    if let c = value as? String {
                                        conf = c
                                    }
                                    if conf == "all-to-all" {
                                        configuration_edit[new_key] = value
                                    }
                                    else {
                                        var cmap = value
                                        if !list_format {
                                            if let list = value as? [[Int]] {
                                                cmap = Coupling.coupling_list2dict(list)
                                            }
                                        }
                                        configuration_edit[new_key] = cmap
                                    }
                                }
                            }
                            responseHandler(configuration_edit,nil)
                            return
                        }
                    }
                }
                for configuration in LocalSimulator.local_configurations {
                    if let name = configuration["name"] as? String {
                        if name == backend {
                            responseHandler(configuration,nil)
                            return
                        }
                    }
                }
                responseHandler(nil,IBMQuantumExperienceError.errorBackend(backend: backend))
            } catch {
                responseHandler(nil,IBMQuantumExperienceError.internalError(error: error))
            }
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
                self.__api.backend_calibration(backend) { (calibrations,error) in
                    if error != nil {
                        responseHandler(nil,error)
                        return
                    }
                    do {
                        var calibrations_edit: [String:Any] = [:]
                        for (key, vals) in calibrations! {
                            let new_key = try QuantumProgram.convert(key)
                            calibrations_edit[new_key] = vals
                        }
                        responseHandler(calibrations_edit,nil)
                    } catch {
                        responseHandler(nil,IBMQuantumExperienceError.internalError(error: error))
                    }
                }
                return
            }
            if self.local_backends().contains(backend) {
                responseHandler(["backend" : backend],nil)
                return
            }
            responseHandler(nil,IBMQuantumExperienceError.errorBackend(backend: backend))
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
                self.__api.backend_parameters(backend) { (parameters,error) in
                    if error != nil {
                        responseHandler(nil,error)
                        return
                    }
                    do {
                        var parameters_edit: [String:Any] = [:]
                        for (key, vals) in parameters! {
                            let new_key = try QuantumProgram.convert(key)
                            parameters_edit[new_key] = vals
                        }
                        responseHandler(parameters_edit,nil)
                    } catch {
                        responseHandler(nil,IBMQuantumExperienceError.internalError(error: error))
                    }
                }
                return
            }
            if self.local_backends().contains(backend) {
                responseHandler(["backend" : backend],nil)
                return
            }
            responseHandler(nil,IBMQuantumExperienceError.errorBackend(backend: backend))
        }
    }

    /**
    Compile the circuits into the exectution list.
    This builds the internal "to execute" list which is list of quantum
    circuits to run on different backends.
    Args:
        name_of_circuits (list[str]): circuit names to be compiled.
        backend (str): a string representing the backend to compile to
        config (dict): a dictionary of configurations parameters for the
        compiler
        silent (bool): is an option to print out the compiling information
        or not
        basis_gates (str): a comma seperated string and are the base gates,
            which by default are: u1,u2,u3,cx,id
        coupling_map (dict): A directed graph of coupling::

            {
            control(int):
                [
                    target1(int),
                    target2(int),
                    , ...
                ],
                ...
            }
        eg. {0: [2], 1: [2], 3: [2]}
        initial_layout (dict): A mapping of qubit to qubit::
            {
                ("q", strart(int)): ("q", final(int)),
                ...
            }
            eg.
            {
                ("q", 0): ("q", 0),
                ("q", 1): ("q", 1),
                ("q", 2): ("q", 2),
                ("q", 3): ("q", 3)
            }
        shots (int): the number of shots
        max_credits (int): the max credits to use 3, or 5
        seed (int): the intial seed the simulatros use
    Returns:
        the job id and populates the qobj::
        qobj =
            {
                id: --job id (string),
                config: -- dictionary of config settings (dict)--,
                    {
                    "max_credits" (online only): -- credits (int) --,
                    "shots": -- number of shots (int) --.
                    "backend": -- backend name (str) --
                    }
                circuits:
                    [
                    {
                    "name": --circuit name (string)--,
                    "compiled_circuit": --compiled quantum circuit (DAG format)--,
                    "config": --dictionary of additional config settings (dict)--,
                        {
                        "coupling_map": --adjacency list (dict)--,
                        "basis_gates": --comma separated gate names (string)--,
                        "layout": --layout computed by mapper (dict)--,
                        "seed": (simulator only)--initial seed for the simulator (int)--,
                        }
                    },
                    ...
                ]
            }
    */
    @discardableResult
    public func compile(_ name_of_circuits: [String],
                        backend: String = "local_qasm_simulator",
                        shots: Int = 1024,
                        max_credits: Int = 3,
                        basis_gates: String? = nil,
                        coupling_map: [Int:[Int]]? = nil,
                        initial_layout: OrderedDictionary<RegBit,RegBit>? = nil,
                        seed: Int? = nil,
                        config: [String:Any]? = nil,
                        silent: Bool = true,
                        qobjid: String? = nil) throws -> [String:Any] {
        // TODO: Jay: currently basis_gates, coupling_map, initial_layout, shots,
        // max_credits and seed are extra inputs but I would like them to go
        // into the config.

        var qobj: [String:Any] = [:]
        let qobjId: String = (qobjid != nil) ? qobjid! : String.randomAlphanumeric(length: 30)
        qobj["id"] = qobjId
        qobj["config"] = ["max_credits": max_credits, "backend": backend, "shots": shots]
        qobj["circuits"] = []

        if name_of_circuits.isEmpty {
            throw QISKitError.missingCircuits
        }

        for name in name_of_circuits {
            guard let qCircuit = self.__quantum_program.circuits[name] else {
                throw QISKitError.missingQuantumProgram(name: name)
            }
            var basis: String = "u1,u2,u3,cx,id"  // QE target basis
            if basis_gates != nil {
                basis = basis_gates!
            }
            // TODO: The circuit object has to have .qasm() method (be careful)
            var dag_circuit = try self.unroller_code(qCircuit.circuit.qasm(), basis)
            var final_layout:OrderedDictionary<RegBit,RegBit>? = nil
            if coupling_map != nil {
                if !silent {
                    print("pre-mapping properties: \(try dag_circuit.property_summary())")
                }
                // Insert swap gates
                let coupling = try Coupling(coupling_map)
                if !silent {
                    print("initial layout: \(initial_layout ?? OrderedDictionary<RegBit,RegBit>())")
                }
                var layout:OrderedDictionary<RegBit,RegBit> = OrderedDictionary<RegBit,RegBit>()
                (dag_circuit, layout) = try Mapping.swap_mapper(dag_circuit, coupling, initial_layout, verbose: false, trials: 20)
                final_layout = layout
                if !silent {
                    print("final layout: \(final_layout!)")
                }

                // Expand swaps
                dag_circuit = try self.unroller_code(try dag_circuit.qasm())
                // Change cx directions
                dag_circuit = try Mapping.direction_mapper(dag_circuit,coupling)
                // Simplify cx gates
                try Mapping.cx_cancellation(dag_circuit)
                // Simplify single qubit gates
                dag_circuit = try Mapping.optimize_1q_gates(dag_circuit)
                if !silent {
                    print("post-mapping properties: \(try dag_circuit.property_summary())")
                }
            }
            // making the job to be added to qoj
            var job: [String:Any] = [:]
            job["name"] = name
            // config parameters used by the runner
            var s: Int = 0
            if seed != nil {
                s = seed!
            }
            else {
                s = Int(arc4random())
            }
            if var conf = config {
                conf["seed"] = s
                job["config"] = conf
            }
            else {
                job["config"] = ["seed":s]
            }
            // TODO: Jay: make config options optional for different backends
            if let map = coupling_map {
                job["coupling_map"] = Coupling.coupling_dict2list(map)
            }
            // Map the layout to a format that can be json encoded
            if let layout = final_layout {
                var list_layout: [[[String:Int]]] = []
                for (k,v) in layout {
                    let kDict = [k.name : k.index]
                    let vDict = [v.name : v.index]
                    list_layout.append([kDict,vDict])
                }
                job["layout"] = layout
            }
            job["basis_gates"] = basis

            // the compuled circuit to be run saved as a dag
            job["compiled_circuit"] = try self._dag2json(dag_circuit)
            job["compiled_circuit_qasm"] = try dag_circuit.qasm(qeflag:true)
            // add job to the qobj
            if var circuits = qobj["circuits"] as? [Any] {
                circuits.append(job)
                qobj["circuits"] = circuits
            }
        }
        return qobj
    }

    /**
     Print the compiled circuits that are ready to run.
     Args:
     verbose (bool): controls how much is returned.
     */
    @discardableResult
    public func get_execution_list(_ qobj: [String: Any], _ verbose: Bool = false) -> [String] {
        var execution_list: [String] = []
        if verbose {
            if let iden = qobj["id"] as? String {
                print("id: \(iden)")
            }
            if let config = qobj["config"] as? [String:Any] {
                if let backend = config["backend"] as? String {
                    print("backend: \(backend)")
                }
                print("qobj config:")
                for (key,value) in config {
                    if key != "backend" {
                        print(" \(key) : \(value)")
                    }
                }
            }
        }
        if let circuits = qobj["circuits"] as? [String:[String:Any]] {
            for (_,circuit) in circuits {
                if let name = circuit["name"] as? String {
                    execution_list.append(name)
                    if verbose {
                        print("  circuit name: \(name)")
                    }
                }
                if verbose {
                    if let config = circuit["config"] as? [String:Any] {
                        print("  circuit config:")
                        for (key,value) in config {
                            print("   \(key) : \(value)")
                        }
                    }
                }
            }
        }
        return execution_list
    }

    /**
     Get the compiled layout for the named circuit and backend.
     Args:
        name (str):  the circuit name
        qobj (str): the name of the qobj
     Returns:
        the config of the circuit.
     */
    public func get_compiled_configuration(_ qobj: [String: Any], _ name: String) throws -> [String:Any] {
        if let circuits = qobj["circuits"]  as? [[String:Any]] {
            for circuit in circuits {
                if let n = circuit["name"] as? String {
                    if n == name {
                        if let config = circuit["config"] as? [String:Any] {
                            return config
                        }
                    }
                }
            }
        }
        throw QISKitError.missingCompiledConfig
    }

    /**
     Print the compiled circuit in qasm format.
     Args:
        qobj (str): the name of the qobj
        name (str): name of the quantum circuit
     */
    public func get_compiled_qasm(_ qobj: [String: Any], _ name: String) throws -> String {
        if let circuits = qobj["circuits"]  as? [[String:Any]] {
            for circuit in circuits {
                if let n = circuit["name"] as? String {
                    if n == name {
                        if let circuit = circuit["compiled_circuit_qasm"] as? String {
                            return circuit
                        }
                    }
                }
            }
        }
        throw QISKitError.missingCompiledQasm
    }

    /**
     Make a Json representation of the circuit.
     Takes a circuit dag and returns json circuit obj. This is an internal
     function.
     Args:
     dag_circuit (dag object): a dag representation of the circuit
     Returns:
     the json version of the dag
     */
    private func _dag2json(_ dag_circuit: DAGCircuit) throws -> String {
        // TODO: Jay: I think this needs to become a method like .qasm() for the DAG.
        let circuit_string = try dag_circuit.qasm(qeflag:true)
        let basis_gates = "u1,u2,u3,cx,id"  // QE target basis
        let unroller = Unroller(try Qasm(data:circuit_string).parse(), JsonBackend(basis_gates.components(separatedBy:",")))
        return try unroller.execute() as! String
    }

    /**
     Unroll the code.
     Circuit is the circuit to unroll using the DAG representation.
     This is an internal function.
     Args:
     qasmString
     basis_gates (str): a comma seperated string and are the base gates,
     which by default are: u1,u2,u3,cx,id
     Return:
        dag_circuit (dag object): a dag representation of the circuit
            unrolled to basis gates
     */
    private func unroller_code(_ qasmString: String, _ basis_gates: String? = nil) throws -> DAGCircuit {
        var basis = "u1,u2,u3,cx,id"  // QE target basis
        if let b = basis_gates {
            basis = b
        }
        let unrolled_circuit = Unroller(try Qasm(data: qasmString).parse(),
                                        DAGBackend(basis.components(separatedBy:",")))
        let dag_circuit_unrolled = try unrolled_circuit.execute() as! DAGCircuit
        return dag_circuit_unrolled
    }

    /**
     Run a program (a pre-compiled quantum program).
     All input for run comes from qobj
     Args:
     qobj(dict): the dictionary of the quantum object to run
     wait (int): wait time is how long to check if the job is completed
     timeout (int): is time until the execution stops
     silent (bool): is an option to print out the running information or
     not
     Returns:
     status done and populates the internal __quantum_program with the
     data
     */
    public func run(_ qobj: [String: Any], _ wait: Int = 5, _ timeout: Int = 60, _ silent: Bool = true,
                    _ responseHandler: @escaping ((_:Result,_:QISKitError?) -> Void)) {
        guard let config = qobj["config"] as? [String:Any] else {
            responseHandler(Result(),QISKitError.missingBackend(backend: ""))
            return
        }
        guard let backend = config["backend"] as? String else {
            responseHandler(Result(),QISKitError.missingBackend(backend: ""))
            return
        }
        guard let circuits = qobj["circuits"] as? [[String:Any]] else {
            responseHandler(Result(),QISKitError.missingBackend(backend: ""))
            return
        }
        if !silent {
            print("running on backend: \(backend)")
        }
        self.online_backends() { (onlineBackends,error) in
            if error != nil {
                responseHandler(Result(),QISKitError.internalError(error:error!))
                return
            }
            if onlineBackends.contains(backend) {
                if let max_credits = config["max_credits"] as? Int,
                    let shots = config["shots"] as? Int {
                    var jobs: [[String:Any]] = []
                    for job in circuits {
                        if let circuit = job["compiled_circuit_qasm"] as? String {
                            jobs.append(["qasm": circuit])
                        }
                    }
                    self.__api.run_job(qasms: jobs, backend: backend, shots: shots, maxCredits: max_credits) { (json, error) -> Void in
                        if error != nil {
                            responseHandler(Result(),QISKitError.internalError(error: error!))
                            return
                        }
                        guard let result = json else {
                            responseHandler(Result(),QISKitError.missingJobId)
                            return
                        }
                        if let error = result["error"] as? [String:Any] {
                            responseHandler(Result(),QISKitError.errorResult(result: ResultError(error)))
                            return
                        }
                        guard let jobId = result["id"] as? String else {
                            responseHandler(Result(),QISKitError.missingJobId)
                            return
                        }
                        self.wait_for_job(jobId: jobId, wait: wait, timeout: timeout) { (qobj_result, error) -> Void in
                            if error != nil {
                                responseHandler(Result(),QISKitError.internalError(error: error!))
                                return
                            }
                            responseHandler(Result(qobj_result!,qobj),nil)
                        }
                    }
                }
                return
            }
            do {
                // making a list of jobs just for local backends. Name is droped
                // but the list is made ordered
                var jobs: [[String:Any]] = []
                for job in circuits {
                    if let circuit = job["compiled_circuit"],
                    let jobConfig = job["config"] as? [String:Any] {
                        var conf: [String:Any] = [:]
                        for (key,value) in jobConfig {
                            conf[key] = value
                        }
                        for (key,value) in config {
                            conf[key] = value
                        }
                        jobs.append(["compiled_circuit": circuit, "config": conf])
                    }
                }
                let qobj_result = try QuantumProgram._run_local_simulator(backend, jobs, silent)
                if let status = qobj_result["status"]  as? String {
                    if status == "COMPLETED" {
                        if let results = qobj_result["result"] as? [[String:Any]] {
                            assert(circuits.count == results.count, "Internal error in QuantumProgram.run(), job_result")
                        }
                    }
                }
                responseHandler(Result(qobj_result,qobj),nil)
            } catch {
                responseHandler(Result(),QISKitError.internalError(error: error))
            }
        }
    }

    /**
     Wait until all online ran jobs are 'COMPLETED'.
     Args:
         jobid:  id string.
         wait (int):  is the time to wait between requests, in seconds
         timeout (int):  is how long we wait before failing, in seconds
         silent (bool): is an option to print out the running information or
         not
     Returns:
         Dictionary of form::
             job_result_return =
                 [
                     {
                        "data": DATA,
                        "status": DATA,
                     },
                     ...
                 ]
    */
    public func wait_for_job(jobId: String, wait: Int = 5, timeout: Int = 60,_ silent: Bool = true,
                             _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitError?) -> Void)) {
        self.wait_for_job(jobId, wait, timeout, silent, 0, responseHandler)
    }

    private func wait_for_job(_ jobid: String, _ wait: Int, _ timeout: Int, _ silent: Bool, _ elapsed: Int,
                            _ responseHandler: @escaping ((_:[String:Any]?, _:QISKitError?) -> Void)) {
        self.__api.get_job(jobId: jobid) { (result, error) -> Void in
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
                self.wait_for_job(jobid, wait, timeout, silent, elapsed + wait, responseHandler)
            }
        }
    }

    /**
     Run a program of compiled quantum circuits on the local machine.
     Args:
         backend (str): the name of the local simulator to run
         jobs: list of dicts {"compiled_circuit": simulator input data,
         "config": integer num shots}
         Returns:
         Dictionary of form,
         job_results =
            [
                 {
                    "data": DATA,
                    "status": DATA,
                 },
                 ...
            ]
     */
    private class func _run_local_simulator(_ backend: String, _ jobs: [[String:Any]], _ silent: Bool = true) throws -> [String: Any] {
        var job_results: [[String:Any]] = []
        for job in jobs {
            let local_simulator = try LocalSimulator(backend, job)
            try local_simulator.run(silent)
            job_results.append(local_simulator.result)
        }
        return ["status": "COMPLETED", "result": job_results]
    }

    /**
     Execute, compile, and run an array of quantum circuits).
     This builds the internal "to execute" list which is list of quantum
     circuits to run on different backends.
     Args:
         name_of_circuits (list[str]): circuit names to be compiled.
         backend (str): a string representing the backend to compile to
         config (dict): a dictionary of configurations parameters for the
         compiler
         wait (int): wait time is how long to check if the job is completed
         timeout (int): is time until the execution stops
         silent (bool): is an option to print out the compiling information
         or not
         basis_gates (str): a comma seperated string and are the base gates,
         which by default are: u1,u2,u3,cx,id
         coupling_map (dict): A directed graph of coupling::
             {
             control(int):
                 [
                    target1(int),
                    target2(int),
                    , ...
                 ],
                 ...
             }
             eg. {0: [2], 1: [2], 3: [2]}
         initial_layout (dict): A mapping of qubit to qubit
             {
             ("q", strart(int)): ("q", final(int)),
             ...
             }
             eg.
             {
             ("q", 0): ("q", 0),
             ("q", 1): ("q", 1),
             ("q", 2): ("q", 2),
             ("q", 3): ("q", 3)
             }
         shots (int): the number of shots
         max_credits (int): the max credits to use 3, or 5
         seed (int): the intial seed the simulatros use
     Returns:
        status done and populates the internal __quantum_program with the
        data
     */
    public func execute(_ name_of_circuits: [String],
                        backend: String = "local_qasm_simulator",
                        shots: Int = 1024,
                        max_credits: Int = 3,
                        wait: Int = 5,
                        timeout: Int = 60,
                        silent: Bool = true,
                        basis_gates: String? = nil,
                        coupling_map: [Int:[Int]]? = nil,
                        initial_layout: OrderedDictionary<RegBit,RegBit>? = nil,
                        seed: Int? = nil,
                        config: [String:Any]? = nil,
                        _ responseHandler: @escaping ((_:Result,_:QISKitError?) -> Void)) {
        do {
            let qobj = try self.compile(name_of_circuits,
                             backend: backend,
                             shots: shots,
                             max_credits: max_credits,
                             basis_gates: basis_gates,
                             coupling_map: coupling_map,
                             initial_layout: initial_layout,
                             seed: seed,
                             config: config,
                             silent: silent)
            self.run(qobj,wait,timeout,silent,responseHandler)
        } catch {
            if let err = error as? QISKitError {
                responseHandler(Result(),err)
                return
            }
            responseHandler(Result(),QISKitError.internalError(error: error))
        }
    }
}
