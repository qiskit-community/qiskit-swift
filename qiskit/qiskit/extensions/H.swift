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

    public init(_ qubit: QuantumRegister, _ circuit: QuantumCircuit? = nil) {
        super.init("h", [], [qubit], circuit)
    }

    public init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("h", [], [qreg], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
