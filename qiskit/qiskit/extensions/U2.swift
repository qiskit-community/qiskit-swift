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

    public init(_ phi: Double, _ lam: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("u2", [phi,lam], [qubit], circuit)
    }

    public override var description: String {
        let phi = String(format:"%.15f",self.params[0])
        let lam = String(format:"%.15f",self.params[1])
        return self._qasmif("\(name)(\(phi),\(lam)) \(self.args[0].identifier)")
    }
}
