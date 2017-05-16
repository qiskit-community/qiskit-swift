//
//  Measure.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum measurement in the computational basis.
 */
public final class Measure: Instruction {

    public init(_ qreg: QuantumRegister, _ creg: ClassicalRegister) {
        super.init("reset", [], [qreg, creg])
    }

    public init(_ qubit: QuantumRegisterTuple, _ bit: ClassicalRegisterTuple) {
        super.init("measure", [], [qubit,bit])
    }

    public override var description: String {
        return "\(name) \(self.args[0].identifier) -> \(self.args[1].identifier)"
    }
}
