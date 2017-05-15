//
//  QuantumProgram.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class QuantumProgram: CustomStringConvertible {

    public struct QASMCompile {
        public var backend: String = "simulator"
        public var maxCredits: Int = 3
        public var shots: Int = 1024
    }

    public var compile: QASMCompile
    public var circuits: [String:QuantumCircuit] = [:]
    private let api: IBMQuantumExperience

    public var description: String {
        if let circuit = self.circuits["name"] {
            return circuit.description
        }
        return ""
    }

    /**
     Creates Quantum Program object with a given configuration.

     - parameter config: Qconfig object
     - parameter circuit: Quantum circuit
     */
    public init(_ config: Qconfig, _ compile: QASMCompile, _ circuit: QuantumCircuit) {
        self.api = IBMQuantumExperience(config: config)
        self.compile = compile
        self.circuits["name"] = circuit
    }

    /**
     Runs a job and gets its information once its status changes from RUNNING. Asynchronous.

     - parameter wait: wait in seconds
     - parameter timeout: timeout in seconds
     - parameter responseHandler: Closure to be called upon completion
     */
    public func run(_ wait: Int = 5, _ timeout: Int = 60,
                    _ responseHandler: @escaping ((_:GetJobResult?, _:Error?) -> Void)) {
        self.api.runJobToCompletion(qasms: [self.description], backend: self.compile.backend,
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
