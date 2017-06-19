//
//  CouplingError.swift
//  qiskit
//
//  Created by Manoel Marques on 6/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Exception for errors raised by the Coupling object.
 */
public enum CouplingError: LocalizedError, CustomStringConvertible {
    case duplicateregbit(regBit: RegBit)
    case notconnected
    case distancenotcomputed
    case notincouplinggraph(regBit: RegBit)

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .duplicateregbit(let regBit):
            return "'\(regBit.description)' already in coupling graph"
        case .notconnected():
            return "coupling graph not connected"
        case .distancenotcomputed:
            return "distance has not been computed"
        case .notincouplinggraph(let regBit):
            return "'\(regBit.description)' not in coupling graph"
        }
    }
}

