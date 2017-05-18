//
//  S.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 S=diag(1,i) Clifford phase gate.
 */
public final class SGate: CompositeGate {

    public init(_ qubit: QuantumRegisterTuple) {
        super.init("s", [], [qubit])
        _ = self.append(U1Gate(Double.pi/2.0,qubit))
    }
}
