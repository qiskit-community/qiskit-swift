//
//  UBase.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Built-in Single Qubit Gate class
 */
public final class UBase: Gate {

    fileprivate init(_ params: [Double], _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        if params.count != 3 {
            throw QISKitException.not3params
        }
        super.init("U", params, [qubit], circuit)
    }

    public override var description: String {
        let theta = String(format:"%.15f",self.params[0])
        let phi = String(format:"%.15f",self.params[1])
        let lamb = String(format:"%.15f",self.params[2])
        return self._qasmif("\(name)(\(theta),\(phi),\(lamb)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     U(theta,phi,lambda)^dagger = U(-theta,-lambda,-phi)
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
        try self._modifiers(circ.u_base(self.params, self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply U to q
     */
    public func u_base(_ params: [Double], _ q: QuantumRegisterTuple) throws -> UBase {
        try self._check_qubit(q)
        return try self._attach(UBase(params, q, self)) as! UBase
    }
}

extension CompositeGate {

    /**
     Apply U to q
     */
    public func u_base(_ params: [Double], _ q: QuantumRegisterTuple) throws -> UBase {
        try self._check_qubit(q)
        return try self._attach(UBase(params, q, self.circuit)) as! UBase
    }
}
