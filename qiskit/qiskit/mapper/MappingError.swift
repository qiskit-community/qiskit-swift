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
public enum MappingError: Error, CustomStringConvertible {
    case layouterror
    case unexpectedsignature(a: Int, b: Int, c: Int)
    case errorcouplinggraph(cxedge: HashableTuple<RegBit,RegBit>)

    public var description: String {
        switch self {
        case .layouterror:
            return "Layer contains >2 qubit gates"
        case .unexpectedsignature(let a, let b, let c):
            return "cx gate has unexpected signature(\(a),\(b),\(c))"
        case .errorcouplinggraph(let cxedge):
            return "circuit incompatible with CouplingGraph: cx on \(cxedge.one.description),\(cxedge.two.description)"
        }
    }
}
