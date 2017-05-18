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
    private var data: [Instruction] = []
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
        for instruction in self.data {
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
        self.data.append(instruction)
        instruction.circuit = self
        return self
    }

    public func append(contentsOf: [Instruction]) -> QuantumCircuit {
        self.data.append(contentsOf: contentsOf)
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
     Append rhs to self if self contains rhs's registers.
     Return self + rhs as a new object.
     */
    public func combine(rhs: QuantumCircuit) throws -> QuantumCircuit {
        for register in rhs.regs {
            if !self.has_register(register) {
                throw QISKitException.circuitsnotcompatible
            }
        }
        let circuit = try QuantumCircuit(rhs.regs, rhs.header)
        for instruction in rhs.data {
            instruction.reapply(circuit)
        }
        return circuit
    }

    /**
     Append rhs to self if self contains rhs's registers.
     Return self + rhs as a new object.
     */
    public func extend(rhs: QuantumCircuit) throws -> QuantumCircuit {
        for register in rhs.regs {
            if !self.has_register(register) {
                throw QISKitException.circuitsnotcompatible
            }
        }
        for instruction in rhs.data {
            instruction.reapply(self)
        }
        return self
    }

    /**
     Raise exception if r is not in this circuit or not qreg.
     */
    public func _check_qreg(_ register: QuantumRegister) throws {
        if !self.has_register(register) {
            throw QISKitException.regNotInCircuit(name: register.name)
        }
    }

    /**
     Raise exception if q is not in this circuit or invalid format.
     */
    public func _check_qubit(_ qubit: QuantumRegisterTuple) throws {
        try self._check_qreg(qubit.register)
        try qubit.register.check_range(qubit.index)
    }

    /**
     Raise exception if r is not in this circuit or not creg.
     */
    public func _check_creg(_ register: ClassicalRegister) throws {
        if !self.has_register(register) {
            throw QISKitException.regNotInCircuit(name: register.name)
        }
    }

    /**
     Reset q.
     */
 /*   public func reset(quantum_register: RegisterArgument) {
        if quantum_register is QuantumRegister {
            instructions = InstructionSet()
            for sizes in range(quantum_register.size):
                instructions.add(self.reset((quantum_register, sizes)))

            return instructions
        }
        self._check_qubit(quantum_register as QuantumRegisterTuple)
        return self._attach(Reset(quantum_register, self))*/
}
