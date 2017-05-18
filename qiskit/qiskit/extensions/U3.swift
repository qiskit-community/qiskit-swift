//
//  U3.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Two-pulse single qubit gate
 */
public final class U3Gate: Gate {

    public init(_ theta: Double, _ phi: Double, _ lam: Double, _ qubit: QuantumRegisterTuple) {
        super.init("u2", [theta,phi,lam], [qubit])
    }

    public override var description: String {
        let theta = String(format:"%.15f",self.params[0])
        let phi = String(format:"%.15f",self.params[1])
        let lam = String(format:"%.15f",self.params[2])
        return self._qasmif("\(name)(\(theta),\(phi),\(lam)) \(self.args[0].identifier)")
    }
}
