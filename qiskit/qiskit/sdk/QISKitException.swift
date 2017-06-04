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
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .intructionCircuitNil():
            return "Instruction's circuit not assigned"
        case .regexists(let name):
            return "register '\(name)'already exists"
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
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
