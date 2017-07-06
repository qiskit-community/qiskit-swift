//
//  U3.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Two-pulse single qubit gate
 */
public final class U3Gate: Gate {

    fileprivate init(_ theta: Double, _ phi: Double, _ lam: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("u3", [theta,phi,lam], [qubit], circuit)
    }

    public override var description: String {
        let theta = self.params[0].format(15)
        let phi = self.params[1].format(15)
        let lam = self.params[2].format(15)
        return self._qasmif("\(name)(\(theta),\(phi),\(lam)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     u3(theta, phi, lamb)^dagger = u3(-theta, -lam, -phi)
     */
    public override func inverse() -> Gate {
        self.params[0] = -self.params[0]
        let phi = self.params[1]
        self.params[1] = -self.params[2]
        self.params[2] = -phi
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.u3(self.params[0], self.params[1],self.params[2], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply u3 q.
     */
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u3(theta, phi, lam, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u3 q.
     */
    @discardableResult
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegisterTuple) throws -> U3Gate {
        try  self._check_qubit(q)
        return self._attach(U3Gate(theta, phi, lam, q, self)) as! U3Gate
    }
}

extension CompositeGate {

    /**
     Apply u3 q.
     */
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u3(theta, phi, lam, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u3 q.
     */
    @discardableResult
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegisterTuple) throws -> U3Gate {
        try  self._check_qubit(q)
        return self._attach(U3Gate(theta, phi, lam, q, self.circuit)) as! U3Gate
    }
}
