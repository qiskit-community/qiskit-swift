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
public enum UnrollerException: Error, CustomStringConvertible {
    case errorregname(line: Int, file: String)
    case errorlocalbit(line: Int, file: String)
    case errorlocalparameter(line: Int, file: String)
    case errorundefinedgate(line: Int, file: String)
    case errorqregsize(line: Int, file: String)
    case errorbinop(line: Int, file: String)
    case errorprefix(line: Int, file: String)
    case errorregsize(line: Int, file: String)
    case errorexternal(line: Int, file: String)
    case errortypeindexed(line: Int, file: String)
    case errortype(type: String, line: Int, file: String)
    case errorbackend

    public var description: String {
        switch self {
        case .errorregname(let line,let file):
            return "expected qreg or creg name: line=\(line) file=\(file)"
        case .errorlocalbit(let line,let file):
            return "excepted local bit name: line=\(line) file=\(file)"
        case .errorlocalparameter(let line,let file):
            return "expected local parameter name: line=\(line) file=\(file)"
        case .errorundefinedgate(let line,let file):
            return "internal error undefined gate: line=\(line) file=\(file)"
        case .errorqregsize(let line,let file):
            return "internal error: qreg size mismatch: line=\(line) file=\(file)"
        case .errorbinop(let line,let file):
            return "internal error: undefined binop: line=\(line) file=\(file)"
        case .errorprefix(let line,let file):
            return "internal error: undefined prefix: line=\(line) file=\(file)"
        case .errorregsize(let line,let file):
            return "internal error: reg size mismatch: line=\(line) file=\(file)"
        case .errorexternal(let line,let file):
            return "internal error: undefined external: line=\(line) file=\(file)"
        case .errortypeindexed(let line,let file):
            return "internal error n.type == indexed_id: line=\(line) file=\(file)"
        case .errortype(let type,let line,let file):
            return "internal error: undefined node type \(type): line=\(line) file=\(file)"
        case .errorbackend():
            return "backend not attached"
        }
    }
}
