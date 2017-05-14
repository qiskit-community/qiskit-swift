//
//  QuantumCircuit.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public protocol Instruction: CustomStringConvertible {
}

public protocol Statement: Instruction {
}

public protocol Decl: Statement {
}

public protocol Qop: Statement {
}

public protocol Uop: Qop {
}

public class QId {

    public var identifier: String { return self.ident }
    private let ident: String

    public init(_ identifier: String) {
        self.ident = identifier
    }
}

public final class QuantumCircuit: CustomStringConvertible {

    public let majorVersion: Int = 2
    public let minorVersion: Int = 0
    public var header: String {
        return "OPENQASM \(self.majorVersion).\(self.minorVersion);"
    }
    public var instructions: [Instruction] = []

    public init() {
    }

    public var description: String {
        var text = self.header
        for instruction in self.instructions {
            text.append("\n\(instruction.description)")
            if instruction is Comment || instruction is GateDecl {
                continue
            }
            text.append(";")
        }
        return text
    }

    public func append(_ instruction: Instruction) -> QuantumCircuit {
        self.instructions.append(instruction)
        return self
    }

    public func append(contentsOf: [Instruction]) -> QuantumCircuit {
        self.instructions.append(contentsOf: contentsOf)
        return self
    }

    public static func + (left: QuantumCircuit, right: Instruction) -> QuantumCircuit {
        let qasm = QuantumCircuit()
        return qasm.append(contentsOf: left.instructions).append(right)
    }

    public static func += (left: inout QuantumCircuit, right: Instruction) {
        left.instructions.append(right)
    }
}
