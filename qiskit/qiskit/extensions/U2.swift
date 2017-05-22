//
//  U2.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 One-pulse single qubit gate
 */
public final class U2Gate: Gate {

    fileprivate init(_ phi: Double, _ lam: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("u2", [phi,lam], [qubit], circuit)
    }

    public override var description: String {
        let phi = String(format:"%.15f",self.params[0])
        let lam = String(format:"%.15f",self.params[1])
        return self._qasmif("\(name)(\(phi),\(lam)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     u2(phi,lamb)^dagger = u2(-lamb-pi,-phi+pi)
     */
    public override func inverse() -> Gate {
        let phi = self.params[0]
        self.params[0] = -self.params[1] - Double.pi
        self.params[1] = -phi + Double.pi
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.u2(self.params[0], self.params[1], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply u2 q.
     */
    public func u2(_ phi: Double, _ lam: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u2(phi, lam, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u2 q.
     */
    public func u2(_ phi: Double, _ lam: Double, _ q: QuantumRegisterTuple) throws -> U2Gate {
        try  self._check_qubit(q)
        return self._attach(U2Gate(phi, lam, q, self)) as! U2Gate
    }
}

extension CompositeGate {

    /**
     Apply u2 q.
     */
    public func u2(_ phi: Double, _ lam: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u2(phi, lam, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u2 q.
     */
    public func u2(_ phi: Double, _ lam: Double, _ q: QuantumRegisterTuple) throws -> U2Gate {
        try  self._check_qubit(q)
        return self._attach(U2Gate(phi, lam, q, self.circuit)) as! U2Gate
    }
}
