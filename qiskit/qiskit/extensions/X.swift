//
//  X.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Pauli X (bit-flip) gate.
 */
public final class XGate: Gate {

    fileprivate init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("x", [], [qreg], circuit)
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
        try self._modifiers(circ.x(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply x to q.
     */
    public func x(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.x(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply x to q.
     */
    public func x(_ q: QuantumRegisterTuple) throws -> XGate {
        try  self._check_qubit(q)
        return self._attach(XGate(q, self)) as! XGate
    }
}

extension CompositeGate {

    /**
     Apply x to q.
     */
    public func x(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.x(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply x to q.
     */
    public func x(_ q: QuantumRegisterTuple) throws -> XGate {
        try  self._check_qubit(q)
        return self._attach(XGate(q, self.circuit)) as! XGate
    }
}
