//
//  QISKitException.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 QISKit SDK Exceptions
 */
public enum QISKitException: Error, CustomStringConvertible {

    case intructionCircuitNil
    case regexists(name: String)
    case regnotexists(name: String)
    case controlValueNegative
    case notcreg
    case regNotInCircuit(name: String)
    case regname
    case regsize
    case controlregnotfound(name: String)
    case not3params
    case notqubitgate(qubit: QuantumRegisterTuple)
    case duplicatequbits
    case regindexrange
    case circuitsnotcompatible
    case noarguments
    case missingFileName
    case missingCircuit
    case missingCircuits
    case missingQuantumProgram(name: String)
    case missingCompiledQasm
    case errorShots
    case errorMaxCredit
    case missingStatus
    case timeout
    case errorStatus(status: String)
    case errorLocalSimulator
    case missingJobId
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .intructionCircuitNil():
            return "Instruction's circuit not assigned"
        case .regexists(let name):
            return "register '\(name)'already exists"
        case .regnotexists(let name):
            return "register '\(name)'does not exist"
        case .controlValueNegative():
            return "control value should be non-negative"
        case .notcreg():
            return "expected classical register"
        case .regNotInCircuit(let name):
            return "register '\(name)' not in this circuit"
        case .regname():
            return "invalid OPENQASM register name"
        case .regsize():
             return "register size must be positive"
        case .controlregnotfound(let name):
            return "control register \(name) not found"
        case .not3params():
            return "Expected 3 parameters."
        case .notqubitgate(let qubit):
            return "qubit '\(qubit.identifier)' not argument of gate."
        case .duplicatequbits():
            return "duplicate qubit arguments"
        case .regindexrange():
            return "register index out of range"
        case .circuitsnotcompatible():
            return "circuits are not compatible"
        case .noarguments():
            return "no arguments passed"
        case .missingFileName():
            return "No filename provided"
        case .missingCircuit():
            return "Circuit not found"
        case .missingCircuits():
            return "No circuits"
        case .missingQuantumProgram(let name):
            return "result: \(name) not in QuantumProgram"
        case .missingCompiledQasm():
            return "No compiled qasm for this circuit"
        case .errorShots():
            return "Online devices only support job batches with equal numbers of shots"
        case .errorMaxCredit():
            return "Online devices only support job batches with equal max credit"
        case .missingStatus():
            return "Missing Status"
        case .timeout():
            return "Timeout"
        case .errorStatus(let status):
            return "status: \(status)"
        case .errorLocalSimulator():
            return "Not a local simulator"
        case .missingJobId():
            return "Missing JobId"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
