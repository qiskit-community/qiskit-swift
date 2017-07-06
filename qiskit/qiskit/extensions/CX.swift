//
//  CX.swift
//  qiskit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 controlled-NOT gate.
 */
public final class CnotGate: Gate {

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("cx", [], [ctl,tgt], circuit)
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
        try self._modifiers(circ.cx(self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply CNOT from ctl to tgt.
     */
    @discardableResult
    public func cx(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CnotGate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CnotGate(ctl, tgt, self)) as! CnotGate
    }
}

extension CompositeGate {

    /**
     Apply CNOT from ctl to tgt.
     */
    @discardableResult
    public func cx(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CnotGate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CnotGate(ctl, tgt, self.circuit)) as! CnotGate
    }
}
