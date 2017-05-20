//
//  H.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Hadamard gate.
 */
public final class HGate: Gate {

    fileprivate init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("h", [], [qreg], circuit)
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
        try self._modifiers(circ.h(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply H to q.
     */
    public func h(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.h(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply H to q.
     */
    public func h(_ q: QuantumRegisterTuple) throws -> HGate {
        try  self._check_qubit(q)
        return self._attach(HGate(q, self)) as! HGate
    }
}

extension CompositeGate {

    /**
     Apply H to q.
     */
    public func h(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.h(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply H to q.
     */
    public func h(_ q: QuantumRegisterTuple) throws -> HGate {
        try  self._check_qubit(q)
        return self._attach(HGate(q, self.circuit)) as! HGate
    }
}
