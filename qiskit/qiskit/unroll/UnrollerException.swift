//
//  UnrollerException.swift
//  qiskit
//
//  Created by Manoel Marques on 6/9/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Exception for errors raised by unroller.
 */
public enum UnrollerException: LocalizedError, CustomStringConvertible {
    case errorregname(qasm: String)
    case errorlocalbit(qasm: String)
    case errorlocalparameter(qasm: String)
    case errorundefinedgate(qasm: String)
    case errorqregsize(qasm: String)
    case errorbinop(qasm: String)
    case errorprefix(qasm: String)
    case errorregsize(qasm: String)
    case errorexternal(qasm: String)
    case errortypeindexed(qasm: String)
    case errortype(type: String, qasm: String)
    case errorbackend

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .errorregname(let qasm):
            return "expected qreg or creg name: qasm='\(qasm)"
        case .errorlocalbit(let qasm):
            return "excepted local bit name: qasm='\(qasm)'"
        case .errorlocalparameter(let qasm):
            return "expected local parameter name: qasm='\(qasm)'"
        case .errorundefinedgate(let qasm):
            return "internal error undefined gate: qasm='\(qasm)'"
        case .errorqregsize(let qasm):
            return "internal error: qreg size mismatch: qasm='\(qasm)'"
        case .errorbinop(let qasm):
            return "internal error: undefined binop: qasm='\(qasm)'"
        case .errorprefix(let qasm):
            return "internal error: undefined prefix: qasm='\(qasm)'"
        case .errorregsize(let qasm):
            return "internal error: reg size mismatch: qasm='\(qasm)'"
        case .errorexternal(let qasm):
            return "internal error: undefined external: qasm='\(qasm)'"
        case .errortypeindexed(let qasm):
            return "internal error n.type == indexed_id: qasm='\(qasm)'"
        case .errortype(let type,let qasm):
            return "internal error: undefined node type \(type): qasm='\(qasm)'"
        case .errorbackend():
            return "backend not attached"
        }
    }
}
