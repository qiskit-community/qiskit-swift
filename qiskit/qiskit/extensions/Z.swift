//
//  Z.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Pauli Z (phase-flip) gate.
 */
public final class ZGate: Gate {

    public init(_ qubit: QuantumRegister) {
        super.init("z", [], [qubit])
    }

    public init(_ qreg: QuantumRegisterTuple) {
        super.init("z", [], [qreg])
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
