//
//  CircuitError.swift
//  qiskit
//
//  Created by Manoel Marques on 5/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Exception for errors raised by the Circuit object.
 */
public enum CircuitError: Error, CustomStringConvertible {
    case duplicateregister(name: String)
    case noregister(name: String)
    case duplicatewire(tuple: HashableTuple<String,Int>)
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .duplicateregister(let name):
            return "duplicate register name '\(name)'"
        case .noregister(let name):
            return "no register name '\(name)'"
        case .duplicatewire(let tuple):
            return "duplicate wire '\(tuple.one)-\(tuple.two)'"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
