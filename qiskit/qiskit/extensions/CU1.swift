//
//  CU1.swift
//  qiskit
//
//  Created by Manoel Marques on 7/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 controlled-U1 gate.
 */
public final class Cu1Gate: Gate {

    fileprivate init(_ theta: Double, _ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("cu1", [theta], [ctl,tgt], circuit)
    }

    public override var description: String {
        let theta = self.params[0].format(15)
        return self._qasmif("\(name)(\(theta)) \(self.args[0].identifier),\(self.args[1].identifier)")
    }

    /**
     Invert this gate.
     */
    public override func inverse() -> Gate {
        self.params[0] = -self.params[0]
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.cu1(self.params[0],self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     pply crz from ctl to tgt with angle theta.
     */
    @discardableResult
    public func cu1(_ theta: Double, _ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> Cu1Gate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(Cu1Gate(theta,ctl, tgt, self)) as! Cu1Gate
    }
}

extension CompositeGate {

    /**
     Apply crz from ctl to tgt with angle theta.
     */
    @discardableResult
    public func cu1(_ theta: Double, _ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> Cu1Gate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(Cu1Gate(theta,ctl, tgt, self.circuit)) as! Cu1Gate
    }
}
