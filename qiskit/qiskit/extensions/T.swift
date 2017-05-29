//
//  T.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 T=sqrt(S) Clifford phase gate.
 */
public final class TGate: CompositeGate {

    fileprivate init(_ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        super.init("t", [], [qubit], circuit)
        _ = try self.u1(Double.pi/4.0,qubit)
    }

    public override var description: String {
        let u1Gate: U1Gate = self.data[0] as! U1Gate
        let qubit = u1Gate.args[0] as! QuantumRegisterTuple
        let phi: Double = u1Gate.params[0]
        if phi > 0 {
            return self.data[0]._qasmif("\(self.name) \(qubit.identifier);")
        }
        return self.data[0]._qasmif("tdg \(qubit.identifier);")
    }


    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.t(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply T to q.
     */
    public func t(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.t(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply T to q.
     */
    public func t(_ q: QuantumRegisterTuple) throws -> TGate {
        try  self._check_qubit(q)
        return self._attach(try TGate(q, self)) as! TGate
    }

    /**
     Apply Tdg to q.
     */
    public func tdg(_ q: QuantumRegisterTuple) throws -> TGate {
        return try self.t(q).inverse() as! TGate
    }
    
}

extension CompositeGate {

    /**
     Apply T to q.
     */
    public func t(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.t(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply T to q.
     */
    public func t(_ q: QuantumRegisterTuple) throws -> TGate {
        try  self._check_qubit(q)
        return self._attach(try TGate(q, self.circuit)) as! TGate
    }

    /**
     Apply Tdg to q.
     */
    public func tdg(_ q: QuantumRegisterTuple) throws -> TGate {
        return try self.t(q).inverse() as! TGate
    }
    
}
