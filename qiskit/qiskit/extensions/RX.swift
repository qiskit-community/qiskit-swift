//
//  RX.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 rotation around the x-axis
 */
public final class RXGate: Gate {

    fileprivate init(_ theta: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("rx", [theta], [qubit], circuit)
    }

    public override var description: String {
        let theta = String(format:"%.15f",self.params[0])
        return self._qasmif("\(name)(\(theta)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     rx(theta)^dagger = rx(-theta)
     */
    public override func inverse() -> Gate {
        self.params[0] = -self.params[0]
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.rx(self.params[0], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply rx to q.
     */
    public func rx(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.rx(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply rx to q.
     */
    public func rx(_ theta: Double, _ q: QuantumRegisterTuple) throws -> RXGate {
        try  self._check_qubit(q)
        return self._attach(RXGate(theta, q, self)) as! RXGate
    }
}

extension CompositeGate {

    /**
     Apply rx to q.
     */
    public func rx(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.rx(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply rx to q.
     */
    public func rx(_ theta: Double, _ q: QuantumRegisterTuple) throws -> RXGate {
        try  self._check_qubit(q)
        return self._attach(RXGate(theta, q, self.circuit)) as! RXGate
    }
}
