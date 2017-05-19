//
//  Y.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Pauli Y (bit-phase-flip) gate.
 */
public final class YGate: Gate {

    public init(_ qubit: QuantumRegister, _ circuit: QuantumCircuit? = nil) {
        super.init("y", [], [qubit], circuit)
    }

    public init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("y", [], [qreg], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
