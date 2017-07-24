//
//  SimulatorError.swift
//  qiskit
//
//  Created by Manoel Marques on 7/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Exception for errors raised by the Simulator object.
*/
public enum SimulatorError: LocalizedError, CustomStringConvertible {
    case unknownSimulator(name: String)
   
    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .unknownSimulator(let name):
            return "Unknown simulator '\(name)'"
        }
    }
}
