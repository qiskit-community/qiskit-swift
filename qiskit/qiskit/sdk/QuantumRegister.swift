//
//  QuantumRegister.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Qubits Register class
 */
public final class QuantumRegister: Register, Decl {

    public override init(_ identifier: String, _ size: Int) throws {
        try super.init(identifier, size)
    }

    public var description: String {
        return "qreg \(self.identifier)[\(self.size)]"
    }
}
