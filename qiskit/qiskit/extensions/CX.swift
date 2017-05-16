//
//  CX.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 controlled-NOT gate.
 */
public final class CnotGate: Gate {

    public init(_ ctl: QuantumRegister, _ tgt: QuantumRegister) {
        super.init("cx", [], [ctl, tgt])
    }

    public init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple) {
        super.init("cx", [], [ctl,tgt])
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }
}
