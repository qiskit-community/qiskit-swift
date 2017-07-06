//
//  RY.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 rotation around the y-axis
 */
public final class RYGate: Gate {

    fileprivate init(_ theta: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("ry", [theta], [qubit], circuit)
    }

    public override var description: String {
        let theta = self.params[0].format(15)
        return self._qasmif("\(name)(\(theta)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     ry(theta)^dagger = ry(-theta)
     */
    public override func inverse() -> Gate {
        self.params[0] = -self.params[0]
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.ry(self.params[0], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply ry to q.
     */
    public func ry(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.ry(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply ry to q.
     */
    public func ry(_ theta: Double, _ q: QuantumRegisterTuple) throws -> RYGate {
        try  self._check_qubit(q)
        return self._attach(RYGate(theta, q, self)) as! RYGate
    }
}

extension CompositeGate {

    /**
     Apply ry to q.
     */
    public func ry(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.ry(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply ry to q.
     */
    public func ry(_ theta: Double, _ q: QuantumRegisterTuple) throws -> RYGate {
        try  self._check_qubit(q)
        return self._attach(RYGate(theta, q, self.circuit)) as! RYGate
    }
}
