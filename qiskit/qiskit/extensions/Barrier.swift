//
//  Barrier.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/12/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum Barrier class
 */
public final class Barrier: Instruction {

    public init(_ qreg: QuantumRegister) {
        super.init("barrier", [], [qreg])
    }

    public init(_ qargs: [QuantumRegisterTuple]) {
        super.init("barrier", [], qargs)
    }

    public override var description: String {
        var text = "barrier "
        for i in 0..<self.args.count {
            if i > 0 {
                text.append(",")
            }
            text.append(self.args[i].identifier)
        }
        return text
    }
}
