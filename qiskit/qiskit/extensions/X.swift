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

    public init(_ qubit: QuantumRegister, _ circuit: QuantumCircuit? = nil) {
        super.init("x", [], [qubit], circuit)
    }

    public init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("x", [], [qreg], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
