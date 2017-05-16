//
//  CCX.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Toffoli gate.
 */
public final class ToffoliGate: Gate {

    public init(_ ctl1: QuantumRegister, _ ctl2: QuantumRegister, _ tgt:QuantumRegister) {
        super.init("ccx", [], [ctl1, ctl2, tgt])
    }

    public init(_ ctl1:QuantumRegisterTuple, _ ctl2:QuantumRegisterTuple, _ tgt:QuantumRegisterTuple) {
        super.init("ccx", [], [ctl1, ctl2, tgt])
    }

    public override var description: String {
        return self._qasmif("\(self.name) \(self.args[0].identifier),\(self.args[1].identifier),\(self.args[2].identifier)")
    }
}
