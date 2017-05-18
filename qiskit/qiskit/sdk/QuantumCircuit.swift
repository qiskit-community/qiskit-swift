//
//  QuantumCircuit.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 5/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public class QuantumCircuitHeader {

    public var name: String {
        return "OPENQASM"
    }
    public var majorVersion: Int {
        return 2
    }
    public var minorVersion: Int {
        return 0
    }
    public var value: String {
        return "\(self.name) \(self.majorVersion).\(self.minorVersion);"
    }

    public init() {
    }
}

public final class QuantumCircuit: CustomStringConvertible {

    public let header: QuantumCircuitHeader
    public let name: String = "qasm"
    private var instructions: [Instruction] = []
    private var regNames: Set<String> = []
    private var regs: [Register] = []

    public init(_ regs: [Register], _ header: QuantumCircuitHeader = QuantumCircuitHeader()) throws {
        self.header = header
        try self.add(regs)
    }

    private init() {
        self.header = QuantumCircuitHeader()
    }

    public var description: String {
        var text = self.header.value
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
