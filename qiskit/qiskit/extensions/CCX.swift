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

    public init(ctl1:(Register,Int), ctl2:(Register,Int), tgt:(Register,Int), circ: QuantumCircuit? = nil) throws {
        try super.init("ccx", [], [ctl1, ctl2, tgt], circ, [], [])
    }

    public override var description: String {
        let ctl1 = self.arg[0]
        let ctl2 = self.arg[1]
        let tgt = self.arg[2]
        return "\(self.name) \(ctl1.0.name)[\(ctl1.1)],\(ctl2.0.name)[\(ctl2.1)],\(tgt.0.name)[\(tgt.1)]"
    }
}
