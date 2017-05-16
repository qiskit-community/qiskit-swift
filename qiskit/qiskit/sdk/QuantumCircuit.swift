//
//  QuantumCircuit.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class QuantumCircuit: CustomStringConvertible {

    private let majorVersion: Int = 2
    private let minorVersion: Int = 0
    private var header: String {
        return "OPENQASM \(self.majorVersion).\(self.minorVersion);\ninclude \"qelib1.inc\";"
    }
    private var instructions: [Instruction] = []
    private var regNames: Set<String> = []
    private var regs: [Register] = []
    public let name: String = "qasm"

    public init(_ regs: [Register]) throws {
        try self.add(regs)
    }

    private init() {
    }


    public var description: String {
        var text = self.header
        for register in self.regs {
            text.append("\n\(register.description);")
        }
        for instruction in self.instructions {
            text.append("\n\(instruction.description);")
        }
        return text
    }

    /**
     Add registers.
     */
    public func add(_ regs: [Register]) throws {
        for register in regs {
            if self.regNames.contains(register.name) {
                throw QISKitException.regexists(name: register.name)
            }
            self.regs.append(register)
            self.regNames.insert(register.name)
        }
    }

    public func append(_ instruction: Instruction) -> QuantumCircuit {
        self.instructions.append(instruction)
        instruction.circuit = self
        return self
    }

    public func append(contentsOf: [Instruction]) -> QuantumCircuit {
        self.instructions.append(contentsOf: contentsOf)
        for instruction in contentsOf {
            instruction.circuit = self
        }
        return self
    }

    public static func + (left: QuantumCircuit, right: Instruction) -> QuantumCircuit {
        let qasm = QuantumCircuit()
        qasm.regs = left.regs
        right.circuit = qasm
        return qasm.append(contentsOf: left.instructions).append(right)
    }

    public static func += (left: inout QuantumCircuit, right: Instruction) {
        let _ = left.append(right)
    }

    /**
     Test if this circuit has the register r.
     Return True or False.
     */
    func has_register(_ register: Register) -> Bool {
        for reg in self.regs {
            if reg.name == register.name && reg.size == register.size {
                if ((register is QuantumRegister && reg is QuantumRegister) ||
                    (register is ClassicalRegister && reg is ClassicalRegister)) {
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
