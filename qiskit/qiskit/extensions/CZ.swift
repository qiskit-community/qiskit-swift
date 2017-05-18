//
//  CZ.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 controlled-Phase gate.
 */
public final class CzGate: Gate {

    public init(_ ctl: QuantumRegister, _ tgt: QuantumRegister) {
        super.init("cz", [], [ctl, tgt])
    }

    public init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple) {
        super.init("cz", [], [ctl,tgt])
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }
}

