//
//  CompositeGate.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Composite gate, a sequence of unitary gates.
 */
public class CompositeGate: Gate {

    private var data: [Instruction] = []  // gate sequence defining the composite unitary
    private var inverse_flag = false

    override init(_ name: String, _ params: [Double], _ qargs: [QuantumRegister]) {
        super.init(name, params, qargs)
    }

    override init(_ name: String, _ params: [Double], _ args: [QuantumRegisterTuple]) {
        super.init(name, params, args)
    }

    public override var description: String {
        var text = ""
        for statement in self.data {
            text.append("\n\(statement.description);")
        }
        return text
    }

    public func append(_ instruction: Instruction) -> CompositeGate {
        self.data.append(instruction)
        instruction.circuit = self.circuit
        return self
    }

    public func append(contentsOf: [Instruction]) -> CompositeGate {
        self.data.append(contentsOf: contentsOf)
        for instruction in contentsOf {
            instruction.circuit = self.circuit
        }
        return self
    }

    public static func += (left: inout CompositeGate, right: Instruction) {
        let _ = left.append(right)
    }
}
