//
//  CXBase.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Fundamental controlled-NOT gate.
 */
public final class CXBase: Gate {

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("CX", [], [ctl,tgt], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
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
        try self._modifiers(circ.cx_base(self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply CX from ctl, tgt.
     */
    public func cx_base(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CXBase {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CXBase(ctl, tgt, self)) as! CXBase
    }
}

extension CompositeGate {

    /**
     Apply CX from ctl, tgt.
     */
    public func cx_base(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CXBase {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CXBase(ctl, tgt, self.circuit)) as! CXBase
    }
}
