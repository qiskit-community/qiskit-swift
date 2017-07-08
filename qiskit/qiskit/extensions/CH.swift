//
//  CH.swift
//  qiskit
//
//  Created by Manoel Marques on 7/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 controlled-H gate.
 */
public final class CHGate: Gate {

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("ch", [], [ctl,tgt], circuit)
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
        try self._modifiers(circ.ch(self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply CH from ctl to tgt.
     */
    @discardableResult
    public func ch(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CHGate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CHGate(ctl, tgt, self)) as! CHGate
    }
}

extension CompositeGate {

    /**
     Apply CH from ctl to tgt.
     */
    @discardableResult
    public func ch(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CHGate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CHGate(ctl, tgt, self.circuit)) as! CHGate
    }
}
