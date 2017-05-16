//
//  X.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Pauli X (bit-flip) gate.
 */
public final class XGate: Gate {

    public init(_ qubit: QuantumRegister) {
        super.init("x", [], [qubit])
    }

    public init(_ qreg: QuantumRegisterTuple) {
        super.init("x", [], [qreg])
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
