//
//  Y.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Pauli Y (bit-phase-flip) gate.
 */
public final class YGate: Gate {

    fileprivate init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("y", [], [qreg], circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
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
        try self._modifiers(circ.y(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply y to q.
     */
    public func y(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.y(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply y to q.
     */
    @discardableResult
    public func y(_ q: QuantumRegisterTuple) throws -> YGate {
        try  self._check_qubit(q)
        return self._attach(YGate(q, self)) as! YGate
    }
}

extension CompositeGate {

    /**
     Apply y to q.
     */
    public func y(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.y(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply y to q.
     */
    @discardableResult
    public func y(_ q: QuantumRegisterTuple) throws -> YGate {
        try  self._check_qubit(q)
        return self._attach(YGate(q, self.circuit)) as! YGate
    }
}
