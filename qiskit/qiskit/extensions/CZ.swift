//
//  CZ.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 controlled-Phase gate.
 */
public final class CzGate: Gate {

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("cz", [], [ctl,tgt], circuit)
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
        try self._modifiers(circ.cz(self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply CZ to circuit.
     */
    public func cz(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CzGate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CzGate(ctl, tgt, self)) as! CzGate
    }
}

extension CompositeGate {

    /**
     Apply CZ to circuit.
     */
    public func cz(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CzGate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CzGate(ctl, tgt, self.circuit)) as! CzGate
    }
}
