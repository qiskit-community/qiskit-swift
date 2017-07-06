//
//  CCX.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Toffoli gate.
 */
public final class ToffoliGate: Gate {

    fileprivate init(_ ctl1:QuantumRegisterTuple, _ ctl2:QuantumRegisterTuple, _ tgt:QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("ccx", [], [ctl1, ctl2, tgt], circuit)
    }

    public override var description: String {
        return self._qasmif("\(self.name) \(self.args[0].identifier),\(self.args[1].identifier),\(self.args[2].identifier)")
    }

    /**
     Invert this gate.
     */
    public override func inverse() -> Gate {
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.ccx(self.args[0] as! QuantumRegisterTuple,
                                     self.args[1] as! QuantumRegisterTuple,
                                     self.args[2] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply Toffoli to circuit.
     */
    @discardableResult
    public func ccx(_ ctl1: QuantumRegisterTuple, _ ctl2: QuantumRegisterTuple, _ tgt:QuantumRegisterTuple) throws -> ToffoliGate {
        try  self._check_qubit(ctl1)
        try  self._check_qubit(ctl2)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl1, ctl2, tgt])
        return self._attach(ToffoliGate(ctl1, ctl2, tgt, self)) as! ToffoliGate
    }
}

extension CompositeGate {

    /**
     Apply Toffoli to circuit.
     */
    @discardableResult
    public func ccx(_ ctl1: QuantumRegisterTuple, _ ctl2: QuantumRegisterTuple, _ tgt:QuantumRegisterTuple) throws -> ToffoliGate {
        try  self._check_qubit(ctl1)
        try  self._check_qubit(ctl2)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl1, ctl2, tgt])
        return self._attach(ToffoliGate(ctl1, ctl2, tgt, self.circuit)) as! ToffoliGate
    }
}
