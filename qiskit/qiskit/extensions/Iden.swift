//
//  Iden.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Identity gate.
 */
public final class IdGate: Gate {

    public init(_ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("id", [], [qubit], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }
}
