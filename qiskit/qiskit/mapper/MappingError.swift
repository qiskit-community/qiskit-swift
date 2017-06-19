//
//  MappingError.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Exception for errors raised by the Mapping object.
 */
public enum MappingError: LocalizedError, CustomStringConvertible {
    case layouterror
    case unexpectedsignature(a: Int, b: Int, c: Int)
    case errorcouplinggraph(cxedge: TupleRegBit)
    case errorqubitscouplinggraph
    case errorqubitinputcircuit(regBit: RegBit)
    case errorqubitincouplinggraph(regBit: RegBit)
    case swapmapperfailed(i: Int, j: Int, qasm: String)

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .layouterror:
            return "Layer contains >2 qubit gates"
        case .unexpectedsignature(let a, let b, let c):
            return "cx gate has unexpected signature(\(a),\(b),\(c))"
        case .errorcouplinggraph(let cxedge):
            return "circuit incompatible with CouplingGraph: cx on \(cxedge.one.description),\(cxedge.two.description)"
        case .errorqubitscouplinggraph:
            return "Not enough qubits in CouplingGraph"
        case .errorqubitinputcircuit(let regBit):
            return "initial_layout qubit \(regBit.description) not in input Circuit"
        case .errorqubitincouplinggraph(let regBit):
            return "initial_layout qubit \(regBit.description) not in input CouplingGraph"
        case .swapmapperfailed(let i, let j, let qasm):
            return "swap_mapper failed: layer \(i), sublayer \(j), \"\(qasm)\""
        }
    }
}
