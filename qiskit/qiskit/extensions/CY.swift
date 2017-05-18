//
//  CY.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 controlled-Y gate.
 */
public final class CyGate: Gate {

    public init(_ ctl: QuantumRegister, _ tgt: QuantumRegister) {
        super.init("cy", [], [ctl, tgt])
    }

    public init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple) {
        super.init("cy", [], [ctl,tgt])
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }
}

