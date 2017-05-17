//
//  QuantumProgram.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class QuantumProgram {

    public final class QASMCompile {
        public var backend: String = "simulator"
        public var maxCredits: Int = 3
        public var shots: Int = 1024

        public init() {
        }
    }

    public var compile: QASMCompile
    private var circuits: [String:QuantumCircuit] = [:]
    private let api: IBMQuantumExperience


    /**
     Creates Quantum Program object with a given configuration.

     - parameter config: Qconfig object
     - parameter circuit: Quantum circuit
     */
    public init(_ config: Qconfig, _ compile: QASMCompile, _ circuit: QuantumCircuit) {
        self.api = IBMQuantumExperience(config: config)
        self.compile = compile
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
        self.api.runJobToCompletion(qasms: qasms, backend: self.compile.backend,
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
        self.api.getExecution(idExecution, responseHandler: responseHandler)
    }

    /**
     Gets execution result information. Asynchronous.

     - parameter idExecution: execution identifier
     - parameter responseHandler: Closure to be called upon completion
     */
    public func getResultFromExecution(_ idExecution: String,
                                       responseHandler: @escaping ((_:GetExecutionResult.Result?, _:Error?) -> Void)) {
        self.api.getResultFromExecution(idExecution, responseHandler: responseHandler)
    }
}
