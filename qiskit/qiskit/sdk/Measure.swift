//
//  Measure.swift
//  qiskit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Quantum measurement in the computational basis.
 */
public final class Measure: Instruction {

    init(_ qubit: QuantumRegisterTuple, _ bit: ClassicalRegisterTuple, _ circuit: QuantumCircuit?) {
        super.init("measure", [], [qubit,bit], circuit)
    }

    public override var description: String {
        return "\(name) \(self.args[0].identifier) -> \(self.args[1].identifier)"
    }

    /**
     Reapply this instruction to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.measure(self.args[0] as! QuantumRegisterTuple,
                                     self.args[1] as! ClassicalRegisterTuple))
    }
}
