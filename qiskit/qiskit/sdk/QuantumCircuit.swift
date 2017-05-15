//
//  QuantumCircuit.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public protocol QInstruction: CustomStringConvertible {
}

public protocol Statement: QInstruction {
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
    public var instructions: [QInstruction] = []
    private var regs: [String:Register] = [:]

    public init() {
    }

    public var description: String {
        var text = self.header
        for instruction in self.instructions {
            text.append("\n\(instruction.description)")
            if instruction is Comment || instruction is CompositeGate {
                continue
            }
            text.append(";")
        }
        return text
    }

    public func append(_ instruction: QInstruction) -> QuantumCircuit {
        self.instructions.append(instruction)
        return self
    }

    public func append(contentsOf: [QInstruction]) -> QuantumCircuit {
        self.instructions.append(contentsOf: contentsOf)
        return self
    }

    public static func + (left: QuantumCircuit, right: QInstruction) -> QuantumCircuit {
        let qasm = QuantumCircuit()
        return qasm.append(contentsOf: left.instructions).append(right)
    }

    public static func += (left: inout QuantumCircuit, right: QInstruction) {
        left.instructions.append(right)
    }

    /**
     Test if this circuit has the register r.
     Return True or False.
     */
    func has_register(_ register: Register) -> Bool {
        if let registers = self.regs[register.name] {
            if registers.size == register.size {
                if ((register is QuantumRegister && registers is QuantumRegister) ||
                    (register is ClassicalRegister && registers is ClassicalRegister)) {
                    return true
                }
            }
        }
        return false
    }

    /**
     Raise exception if r is not in this circuit or not creg.
     */
    func check_creg(_ register: Register) throws {
        if register is ClassicalRegister {
            if !self.has_register(register) {
                throw QISKitException.regNotInCircuit(name: register.name)
            }
        }
        else {
            throw QISKitException.notcreg
        }
    }
}
