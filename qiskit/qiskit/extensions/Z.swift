//
//  Z.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Pauli Z (phase-flip) gate.
 */
public final class ZGate: Gate {

    fileprivate init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("z", [], [qreg], circuit)
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
        try self._modifiers(circ.z(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply z to q.
     */
    public func z(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.z(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply z to q.
     */
    public func z(_ q: QuantumRegisterTuple) throws -> ZGate {
        try  self._check_qubit(q)
        return self._attach(ZGate(q, self)) as! ZGate
    }
}

extension CompositeGate {

    /**
     Apply z to q.
     */
    public func z(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.z(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply z to q.
     */
    public func z(_ q: QuantumRegisterTuple) throws -> ZGate {
        try  self._check_qubit(q)
        return self._attach(ZGate(q, self.circuit)) as! ZGate
    }
}
