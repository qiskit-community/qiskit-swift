//
//  BackendException.swift
//  qiskit
//
//  Created by Manoel Marques on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Exception for errors raised by unroller backends.
 */
public enum BackendException: Error, CustomStringConvertible {
    case erroropaque(name: String)
    case qregadded

    public var description: String {
        switch self {
        case .erroropaque(let name):
            return "opaque gate \(name) not in basis"
        case .qregadded():
            return "sorry, already added the qreg; please declare all qregs before applying a gate"
        }
    }
}
