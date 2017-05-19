//
//  CSwap.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Fredkin gate. Controlled-SWAP.
 */
public final class FredkinGate: CompositeGate {

    public init(_ ctl: QuantumRegisterTuple,_ tgt1: QuantumRegisterTuple, _ tgt2: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        super.init("fredkin", [], [ctl,tgt1, tgt2], circuit)
        _ = try self.cx(tgt2,tgt1)
        _ = self.append(ToffoliGate(ctl,tgt1,tgt2, circuit))
        _ = try self.cx(tgt2,tgt1)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }
}
