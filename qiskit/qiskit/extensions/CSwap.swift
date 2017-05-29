//
//  CSwap.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Fredkin gate. Controlled-SWAP.
 */
public final class FredkinGate: CompositeGate {

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt1: QuantumRegisterTuple, _ tgt2: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        super.init("fredkin", [], [ctl,tgt1, tgt2], circuit)
        _ = try self.cx(tgt2,tgt1)
        _ = try self.ccx(ctl,tgt1,tgt2)
        _ = try self.cx(tgt2,tgt1)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.cswap(self.args[0] as! QuantumRegisterTuple,
                                     self.args[1] as! QuantumRegisterTuple,
                                     self.args[2] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply FredkinGate to circuit.
     */
    public func cswap(_ ctl: QuantumRegisterTuple, _ tgt1: QuantumRegisterTuple, _ tgt2:QuantumRegisterTuple) throws -> FredkinGate {
        try  self._check_qubit(ctl)
        try  self._check_qubit(tgt1)
        try self._check_qubit(tgt2)
        try QuantumCircuit._check_dups([ctl, tgt1, tgt2])
        return try self._attach(FredkinGate(ctl, tgt1, tgt2, self)) as! FredkinGate
    }
}

extension CompositeGate {

    /**
     Apply FredkinGate to circuit.
     */
    public func cswap(_ ctl: QuantumRegisterTuple, _ tgt1: QuantumRegisterTuple, _ tgt2:QuantumRegisterTuple) throws -> FredkinGate {
        try  self._check_qubit(ctl)
        try  self._check_qubit(tgt1)
        try self._check_qubit(tgt2)
        try QuantumCircuit._check_dups([ctl, tgt1, tgt2])
        return try self._attach(FredkinGate(ctl, tgt1, tgt2, self.circuit)) as! FredkinGate
    }
}
