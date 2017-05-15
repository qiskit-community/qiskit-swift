//
//  QISKitException.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 QISKit SDK Exceptions
 */
public enum QISKitException: Error, CustomStringConvertible {

    case intructionCircuitNil
    case controlValueNegative
    case notcreg
    case regNotInCircuit(name: String)
    case regname
    case regsize
    case controlregnotfound(name: String)
    case inversenotimpl
    case controlnotimpl
    case notqreg
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .intructionCircuitNil():
            return "Instruction's circuit not assigned"
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
        case .inversenotimpl():
            return "control not implemented"
        case .controlnotimpl():
            return "control not implemented"
        case .notqreg():
            return "argument not QuantumRegister"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
