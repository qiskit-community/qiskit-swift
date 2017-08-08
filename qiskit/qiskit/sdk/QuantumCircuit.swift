// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation

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
    public private(set) var regs: [Register] = []

    public init(_ regs: [Register], _ header: QuantumCircuitHeader = QuantumCircuitHeader()) throws {
        self.header = header
        try self.add(regs)
    }

    public init(_ header: QuantumCircuitHeader = QuantumCircuitHeader()) {
        self.header = header
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
    public func combine(_ rhs: QuantumCircuit) throws -> QuantumCircuit {
        for register in rhs.regs {
            if !self.has_register(register) {
                throw QISKitException.circuitsnotcompatible
            }
        }
        let circuit = try QuantumCircuit(rhs.regs, rhs.header)
        for instruction in rhs.data {
            try instruction.reapply(circuit)
        }
        return circuit
    }

    /**
     Append rhs to self if self contains rhs's registers.
     Return self + rhs as a new object.
     */
    @discardableResult
    public func extend(_ rhs: QuantumCircuit) throws -> QuantumCircuit {
        for register in rhs.regs {
            if !self.has_register(register) {
                throw QISKitException.circuitsnotcompatible
            }
        }
        for instruction in rhs.data {
            try instruction.reapply(self)
        }
        return self
    }
    
    /**
     Overload + to implement self.concatenate.
     */
    public static func + (left: QuantumCircuit, right: QuantumCircuit) throws -> QuantumCircuit {
        return try left.combine(right)
    }

    /**
     Overload += to implement self.extend.
     */
    public static func += (left: inout QuantumCircuit, right: QuantumCircuit) throws {
        try left.extend(right)
    }

    /**
     Attach a instruction.
     */
    public func _attach(_ instruction: Instruction) -> Instruction {
        self.data.append(instruction)
        return instruction
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
     Raise exception if list of qubits contains duplicates.
     */
    public static func _check_dups(_ qubits: [QuantumRegisterTuple]) throws {
        for qubit1 in qubits {
            for qubit2 in qubits {
                if qubit1 === qubit2 {
                    continue
                }
                if qubit1.register.name == qubit2.register.name &&
                    qubit1.index == qubit2.index {
                    throw QISKitException.duplicatequbits
                }
            }
        }
    }

    public func qasm() -> String {
        return self.description
    }


    /**
     Measure quantum register into circuit (tuples).
     */
    @discardableResult
    public func measure(_ quantum_register: QuantumRegisterTuple, _ circuit: ClassicalRegisterTuple) throws -> Measure {
        try self._check_qubit(quantum_register)
        try self._check_creg(circuit.register)
        try circuit.register.check_range(circuit.index)
        return self._attach(Measure(quantum_register, circuit, self)) as! Measure
    }

    /**
     Reset q.
     */
    public func reset(_ quantum_register: QuantumRegister) throws -> InstructionSet {
        let instructions = InstructionSet()
        for sizes in 0..<quantum_register.size {
            instructions.add(try self.reset(QuantumRegisterTuple(quantum_register, sizes)))
        }
        return instructions
    }

    @discardableResult
    public func reset(_ qTuple: QuantumRegisterTuple) throws -> Instruction {
        try self._check_qubit(qTuple)
        return self._attach(Reset(qTuple, self))
    }
}
