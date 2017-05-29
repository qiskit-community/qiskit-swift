//
//  S.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 S=diag(1,i) Clifford phase gate.
 */
public final class SGate: CompositeGate {

    fileprivate init(_ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        super.init("s", [], [qubit], circuit)
        _ = try self.u1(Double.pi/2.0,qubit)
    }

    public override var description: String {
        let u1Gate: U1Gate = self.data[0] as! U1Gate
        let qubit = u1Gate.args[0] as! QuantumRegisterTuple
        let phi: Double = u1Gate.params[0]
        if phi > 0 {
            return self.data[0]._qasmif("\(self.name) \(qubit.identifier);")
        }
        return self.data[0]._qasmif("sdg \(qubit.identifier);")
    }


    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.s(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply S to q.
     */
    public func s(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.s(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply S to q.
     */
    public func s(_ q: QuantumRegisterTuple) throws -> SGate {
        try  self._check_qubit(q)
        return self._attach(try SGate(q, self)) as! SGate
    }

    /**
     Apply Sdg to q.
     */
    public func sdg(_ q: QuantumRegisterTuple) throws -> SGate {
        return try self.s(q).inverse() as! SGate
    }

}

extension CompositeGate {

    /**
     Apply S to q.
     */
    public func s(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.s(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply S to q.
     */
    public func s(_ q: QuantumRegisterTuple) throws -> SGate {
        try  self._check_qubit(q)
        return self._attach(try SGate(q, self.circuit)) as! SGate
    }

    /**
     Apply Sdg to q.
     */
    public func sdg(_ q: QuantumRegisterTuple) throws -> SGate {
        return try self.s(q).inverse() as! SGate
    }
}
