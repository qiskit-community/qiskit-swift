//
//  T.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 T=sqrt(S) Clifford phase gate.
 */
public final class TGate: CompositeGate {

    public init(_ qubit: QuantumRegisterTuple) {
        super.init("t", [], [qubit])
        _ = self.append(U1Gate(Double.pi/4.0,qubit))
    }
}
