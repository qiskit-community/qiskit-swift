//
//  QuantumProgram.swift
//  qiskit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public final class QuantumProgram {

    public final class QASMCompile {
        public var backend: String = "simulator"
        public var maxCredits: Int = 3
        public var shots: Int = 1024

        public init() {
        }
    }

    public final class QProgram {
        public var circuits: [String: QuantumCircuit] = [:]

        public init() {
        }
    }

    public let name: String
    public var compile: QASMCompile
    private var circuits: [String:QuantumCircuit] = [:]
    private var config: Qconfig
    private var __quantum_program: QProgram
    private var __quantum_registers: [String: QuantumRegister] = [:]
    private var __classical_registers: [String: ClassicalRegister] = [:]
    private var __init_circuit: QuantumCircuit? = nil


    public init(_ specs: [String:AnyObject]? = nil, _ name: String = "") throws {
        self.name = ""
        self.compile = QASMCompile()
        self.config  = try Qconfig()
        self.__quantum_program = QProgram()
    
        if let s = specs {
            try self.__init_specs(s)
        }
    }

    /**
     Creates Quantum Program object with a given configuration.

     - parameter config: Qconfig object
     - parameter circuit: Quantum circuit
     */
    public init(_ config: Qconfig, _ compile: QASMCompile, _ circuit: QuantumCircuit) {
        self.name = ""
        self.compile = compile
        self.config = config
        self.__quantum_program = QProgram()
        self.circuits[circuit.name] = circuit
    }

    public func circuit(_ name: String) -> QuantumCircuit? {
        return self.circuits[name]
    }

    /**
     Runs a job and gets its information once its status changes from RUNNING. Asynchronous.

     - parameter wait: wait in seconds
     - parameter timeout: timeout in seconds
     - parameter responseHandler: Closure to be called upon completion
     */
    public func run(_ wait: Int = 5, _ timeout: Int = 60,
                    _ responseHandler: @escaping ((_:GetJobResult?, _:IBMQuantumExperienceError?) -> Void)) {

        var qasms: [String] = []
        for (_,circuit) in self.circuits {
            qasms.append("\(circuit.description)\n")
        }
        let api = IBMQuantumExperience(config: self.config)
        api.runJobToCompletion(qasms: qasms, backend: self.compile.backend,
                                                   shots: self.compile.shots, maxCredits: self.compile.maxCredits,
                                                   wait: wait, timeout: timeout, responseHandler: responseHandler)
    }

    /**
     Gets execution information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getExecution(_ idExecution: String,
                             responseHandler: @escaping ((_:GetExecutionResult?, _:Error?) -> Void)) {
        let api = IBMQuantumExperience(config: self.config)
        api.getExecution(idExecution, responseHandler: responseHandler)
    }

    /**
     Gets execution result information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getResultFromExecution(_ idExecution: String,
                                       responseHandler: @escaping ((_:GetExecutionResult.Result?, _:Error?) -> Void)) {
        let api = IBMQuantumExperience(config: self.config)
        api.getResultFromExecution(idExecution, responseHandler: responseHandler)
    }


    /**
     Populate the Quantum Program Object with initial Specs
     */
    private func __init_specs(_ specs:[String: AnyObject]) throws {
        if let api = specs["api"] as? [String:AnyObject] {
            if let token = api["token"] as? String {
                self.config.apiToken = token
            }
            if let u = api["url"] as? String {
                guard let url = URL(string: u) else {
                    throw IBMQuantumExperienceError.invalidURL(url: u)
                }
                self.config.url = url
            }
        }

        var quantumr:[QuantumRegister] = []
        var classicalr:[ClassicalRegister] = []
        if let circuits = specs["circuits"] as? [AnyObject] {
            for circ in circuits {
                if let circuit = circ as? [String:AnyObject] {
                    if let qregs = circuit["quantum_registers"] as? [AnyObject] {
                        quantumr = try self.create_quantum_registers_group(qregs)
                    }
                    if let cregs = circuit["classical_registers"] as? [AnyObject] {
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
        if let register = specs["quantum_registers"] as? [String:AnyObject] {
            if let name = register["name"] as? String {
                if let size = register["size"] as? NSNumber {
                    qReg = try self.create_quantum_registers(name,size.intValue)
                }
            }
        }
        var cReg: ClassicalRegister? = nil
        if let register = specs["classical_registers"] as? [String:AnyObject] {
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
     Add anew circuit based in a Object representation.
     name is the name or index of one circuit.
     */
    public func add_circuit(name: String, circuit_object: QuantumCircuit) -> QuantumCircuit {
        self.__quantum_program.circuits[name] = circuit_object
        return circuit_object
    }

    /**
     Create a new Quantum Circuit into the Quantum Program
     name is a string, the name of the circuit
     qregisters is a Array of Quantum Registers
     cregisters is a Array of Classical Registers
     */
    private func create_circuit(name: String, qregisters: [QuantumRegister] = [], cregisters: [ClassicalRegister] = [], circuit_object: QuantumCircuit = QuantumCircuit()) throws -> QuantumCircuit {
        self.__quantum_program.circuits[name] = circuit_object

        for register in qregisters {
            try self.__quantum_program.circuits[name]!.add([register])
        }
        for register in cregisters {
            try self.__quantum_program.circuits[name]!.add([register])
        }
        return self.__quantum_program.circuits[name]!
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
    private func create_quantum_registers_group(_ registers_array:[AnyObject]) throws -> [QuantumRegister] {
        var new_registers:[QuantumRegister] = []
        for reg in registers_array {
            if let register = reg as? [String:AnyObject] {
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
     Create a new set of Classical Registers based in a array of that
     */
    private func  create_classical_registers_group(_ registers_array:[AnyObject]) throws -> [ClassicalRegister] {
        var new_registers:[ClassicalRegister] = []
        for reg in registers_array {
            if let register = reg as? [String:AnyObject] {
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
     Create a new set of Classical Registers
     */
    private func  create_classical_registers(_ name: String, _ size: Int) throws -> ClassicalRegister {
        try self.__classical_registers[name] = ClassicalRegister(name, size)
        return self.__classical_registers[name]!
    }
}
