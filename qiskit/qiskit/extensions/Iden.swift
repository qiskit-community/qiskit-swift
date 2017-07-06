//
//  Iden.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Identity gate.
 */
public final class IdGate: Gate {

    fileprivate init(_ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("id", [], [qubit], circuit)
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
        try self._modifiers(circ.iden(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply Identity to q.
     */
    public func iden(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.iden(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply Identity to q.
     */
    @discardableResult
    public func iden(_ q: QuantumRegisterTuple) throws -> IdGate {
        try  self._check_qubit(q)
        return self._attach(IdGate(q, self)) as! IdGate
    }
}

extension CompositeGate {

    /**
     Apply Identity to q.
     */
    public func iden(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.iden(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply Identity to q.
     */
    @discardableResult
    public func iden(_ q: QuantumRegisterTuple) throws -> IdGate {
        try  self._check_qubit(q)
        return self._attach(IdGate(q, self.circuit)) as! IdGate
    }
}
