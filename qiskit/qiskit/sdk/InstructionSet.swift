//
//  InstructionSet.swift
//  qiskit
//
//  Created by Manoel Marques on 5/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class InstructionSet {

    private var instructions: [Instruction] = []

    /**
     Add instruction to set.
     */
    public func add(_ instruction: Instruction) {
        self.instructions.append(instruction)
    }

    /**
     Invert all instructions
     */
    public func inverse() -> InstructionSet {
        for instruction in self.instructions {
            _ = instruction.inverse()
        }
        return self
    }

    /**
     Add controls to all instructions.
     */
    public func q_if(_ qregs:[QuantumRegister]) -> InstructionSet {
        for instruction in self.instructions {
            _ = instruction.q_if(qregs)
        }
        return self
    }

    /**
     Add classical control register to all instructions
     */
    public func c_if(_ c: ClassicalRegister, _ val: Int) throws -> InstructionSet {
        for instruction in self.instructions {
            _ = try instruction.c_if(c, val)
        }
        return self
    }
}
