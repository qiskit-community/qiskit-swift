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
    case duplicatewire(regBit: RegBit)
    case nobasicop(name: String)
    case gatematch
    case qbitsnumber(name: String)
    case bitsnumber(name: String)
    case paramsnumber(name: String)
    case cregcondition(name: String)
    case bitnotfound(q: RegBit)
    case wiretype(bVal: Bool, q: RegBit)
    case incompatiblebasis
    case ineqgate(name: String)
    case wirefrag(name: String)
    case unmappedupname(name: String)
    case invalidwiremapkey(regBit: RegBit)
    case invalidwiremapvalue(regBit: RegBit)
    case inconsistentewiremap(name: RegBit, value: RegBit)
    case duplicateswiremap
    case duplicatewires
    case totalwires(expected: Int, total: Int)
    case missingwire(wire: RegBit)
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .duplicateregister(let name):
            return "duplicate register name '\(name)'"
        case .noregister(let name):
            return "no register name '\(name)'"
        case .duplicatewire(let regBit):
            return "duplicate wire '\(regBit.name)-\(regBit.index)'"
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
            return "(qu)bit \(q.qasm) not found"
        case .wiretype(let bVal, let q):
            return "expected wire type \(bVal) for \(q.qasm)"
        case .incompatiblebasis():
            return "incompatible basis"
        case .ineqgate(let name):
            return "inequivalent gate definitions for \(name)"
        case .wirefrag(let name):
            return "wire_map fragments reg \(name)"
        case .unmappedupname(let name):
            return "unmapped duplicate reg \(name)"
        case .invalidwiremapkey(let regBit):
            return "invalid wire mapping key \(regBit.qasm)"
        case .invalidwiremapvalue(let regBit):
            return "invalid wire mapping value \(regBit.qasm)"
        case .inconsistentewiremap(let name, let value):
            return "inconsistent wire_map at (\(name.qasm),\(value.qasm))"
        case .duplicateswiremap():
            return "duplicates in wire_map"
        case .duplicatewires():
            return "duplicate wires"
        case .totalwires(let expected, let total):
            return "expected \(expected) wires, got \(total)"
        case .missingwire(let w):
            return "wire (\(w.name),\(w.index)) not in input circuit"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
