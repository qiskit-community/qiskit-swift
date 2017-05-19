//
//  CXBase.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Fundamental controlled-NOT gate.
 */
public final class CXBase: Gate {

    public init(_ ctl: QuantumRegister, _ tgt: QuantumRegister, _ circuit: QuantumCircuit? = nil) {
        super.init("CX", [], [ctl, tgt], circuit)
    }

    public init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("CX", [], [ctl,tgt], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }
}
