//
//  Reset.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Qubit reset
 */
public final class Reset: Instruction {

    public init(_ qreg: QuantumRegister) {
        super.init("reset", [], [qreg])
    }

    public init(_ qubit: QuantumRegisterTuple) {
        super.init("reset", [], [qubit])
    }

    public override var description: String {
        return "\(name) \(self.args[0].identifier)"
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(circ: QuantumCircuit) {
       // self._modifiers(circ.reset(self.arg[0]))
    }
}
