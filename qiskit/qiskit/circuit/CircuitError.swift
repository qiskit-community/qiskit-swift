//
//  CircuitError.swift
//  qiskit
//
//  Created by Manoel Marques on 5/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Exception for errors raised by the Circuit object.
 */
public enum CircuitError: Error, CustomStringConvertible {
    case duplicateregister(name: String)
    case noregister(name: String)
    case duplicatewire(tuple: HashableTuple<String,Int>)
    case nobasicop(name: String)
    case gatematch
    case qbitsnumber(name: String)
    case bitsnumber(name: String)
    case paramsnumber(name: String)
    case cregcondition(name: String)
    case bitnotfound(q: HashableTuple<String,Int>)
    case wiretype(bVal: Bool, q: HashableTuple<String,Int>)
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .duplicateregister(let name):
            return "duplicate register name '\(name)'"
        case .noregister(let name):
            return "no register name '\(name)'"
        case .duplicatewire(let tuple):
            return "duplicate wire '\(tuple.one)-\(tuple.two)'"
        case .nobasicop(let name):
            return "\(name) is not in the list of basis operations"
        case .gatematch():
            return "gate data does not match basis element specification"
        case .qbitsnumber(let name):
            return "incorrect number of qubits for \(name)"
        case .bitsnumber(let name):
            return "incorrect number of bits for \(name)"
        case .paramsnumber(let name):
            return "incorrect number of parameters for \(name)"
        case .cregcondition(let name):
            return "invalid creg in condition for \(name)"
        case .bitnotfound(let q):
            return "(qu)bit \(q.one)[\(q.two)] not found"
        case .wiretype(let bVal, let q):
            return "expected wire type \(bVal) for \(q.one)[\(q.two)]"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
