//
//  CU3.swift
//  qiskit
//
//  Created by Manoel Marques on 7/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 controlled-U3 gate.
 */
public final class Cu3Gate: Gate {

    fileprivate init(_ theta: Double,_ phi: Double,_ lam: Double, _ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("cu3", [theta,phi,lam], [ctl,tgt], circuit)
    }

    public override var description: String {
        let theta = self.params[0].format(15)
        let phi = self.params[1].format(15)
        let lam = self.params[2].format(15)
        return self._qasmif("\(name)(\(theta),\(phi),\(lam)) \(self.args[0].identifier),\(self.args[1].identifier)")
    }

    /**
     Invert this gate.
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
        try self._modifiers(circ.cu3(self.params[0],self.params[1],self.params[2],self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     pply crz from ctl to tgt with angle theta.
     */
    @discardableResult
    public func cu3(_ theta: Double,_ phi: Double,_ lam: Double, _ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> Cu3Gate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(Cu3Gate(theta,phi,lam,ctl, tgt, self)) as! Cu3Gate
    }
}

extension CompositeGate {

    /**
     Apply crz from ctl to tgt with angle theta.
     */
    @discardableResult
    public func cu3(_ theta: Double,_ phi: Double,_ lam: Double, _ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> Cu3Gate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(Cu3Gate(theta,phi,lam,ctl, tgt, self.circuit)) as! Cu3Gate
    }
}
