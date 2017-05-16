//
//  H.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Hadamard gate.
 */
public final class HGate: Gate {

    public init(_ qubit: QuantumRegister) {
        super.init("h", [], [qubit])
    }

    public init(_ qreg: QuantumRegisterTuple) {
        super.init("h", [], [qreg])
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
