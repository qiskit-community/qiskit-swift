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

/**
 Quantum Barrier class
 */
public final class Barrier: Instruction {

    public var instructionComponent: InstructionComponent

    fileprivate init(_ qregs: [QuantumRegister], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("barrier", [], qregs, circuit)
    }

    fileprivate init(_ qargs: [QuantumRegisterTuple], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("barrier", [], qargs, circuit)
    }

    fileprivate init(_ qregs: [QuantumRegister], _ gate: CompositeGate) {
        self.instructionComponent = InstructionComponent("barrier", [], qregs, gate.circuit)
    }

    fileprivate init(_ qargs: [QuantumRegisterTuple], _ gate: CompositeGate) {
        self.instructionComponent = InstructionComponent("barrier", [], qargs, gate.circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> Instruction {
        return Barrier(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        var text = "barrier "
        let array = self.args.map {$0.identifier}
        text.append(array.joined(separator: ","))
        return text
    }

    /**
     Special case. Return self.
     */
    public func inverse() -> Instruction {
        return self
    }

    /**
    Reapply this instruction to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        var registers: [QuantumRegister] = []
        var tuples: [QuantumRegisterTuple] = []
        for arg in self.args {
            if arg is QuantumRegister {
                registers.append(arg as! QuantumRegister)
            }
            if arg is QuantumRegisterTuple {
                tuples.append(arg as! QuantumRegisterTuple)
            }
        }
        let barrier = registers.isEmpty ? try circ.barrier(tuples) : try circ.barrier(registers)
        try self._modifiers(barrier)
    }
}

extension QuantumCircuit {

    /**
     Apply barrier to QuantumRegisters
     */
    @discardableResult
    public func barrier(_ regs: [QuantumRegister] = []) throws -> Barrier {
        var registers = regs
        if registers.isEmpty { //TODO: implement this for all single qubit gates
            for (_,register) in self.regs {
                if let reg = register as? QuantumRegister {
                    registers.append(reg)
                }
            }
            if registers.isEmpty {
                throw QISKitError.noArguments
            }
        }
        var qubits: [QuantumRegisterTuple] = []
        for register in registers {
            for j in 0..<register.size {
                let tuple_element = QuantumRegisterTuple(register,j)
                try self._check_qubit(tuple_element)
                qubits.append(tuple_element)
            }
        }
        try QuantumCircuit._check_dups(qubits)
        return self._attach(Barrier(qubits, self)) as! Barrier
    }

    /**
     Apply barrier to QuantumRegister
     */
    @discardableResult
    public func barrier(_ reg: QuantumRegister) throws -> Barrier {
       return try self.barrier([reg])
    }

    /**
     Apply barrier to tuples (reg, idx)
     */
    @discardableResult
    public func barrier(_ qTuples: [QuantumRegisterTuple]) throws -> Barrier {
        var qubits: [QuantumRegisterTuple] = []
        if qTuples.isEmpty { //TODO: implement this for all single qubit gates
            var registers: [QuantumRegister] = []
            for (_,register) in self.regs {
                if let reg = register as? QuantumRegister {
                    registers.append(reg)
                }
            }
            if registers.isEmpty {
                throw QISKitError.noArguments
            }
            for register in registers {
                for j in 0..<register.size {
                    let tuple_element = QuantumRegisterTuple(register,j)
                    try self._check_qubit(tuple_element)
                    qubits.append(tuple_element)
                }
            }
        }
        else {
            for tuple_element in qTuples {
                try self._check_qubit(tuple_element)
                qubits.append(tuple_element)
            }
        }
        try QuantumCircuit._check_dups(qubits)
        return self._attach(Barrier(qubits, self)) as! Barrier
    }
}

extension CompositeGate {

    /**
     Apply barrier to QuantumRegisters
     */
    @discardableResult
    public func barrier(_ regs: [QuantumRegister] = []) throws -> Barrier {
        if regs.isEmpty {
            throw QISKitError.noArguments
        }
        var qubits: [QuantumRegisterTuple] = []
        for register in regs {
            for j in 0..<register.size {
                let tuple_element = QuantumRegisterTuple(register,j)
                try self._check_qubit(tuple_element)
                qubits.append(tuple_element)
            }
        }
        try QuantumCircuit._check_dups(qubits)
        return self._attach(Barrier(qubits, self))
    }

    /**
     Apply barrier to QuantumRegister
     */
    @discardableResult
    public func barrier(_ reg: QuantumRegister) throws -> Barrier {
        return try self.barrier([reg])
    }

    /**
     Apply barrier to tuples (reg, idx)
     */
    @discardableResult
    public func barrier(_ qTuples: [QuantumRegisterTuple]) throws -> Barrier {
        if qTuples.isEmpty {
            throw QISKitError.noArguments
        }
        var qubits: [QuantumRegisterTuple] = []
        if qTuples.isEmpty { //TODO: implement this for all single qubit gates
            throw QISKitError.noArguments
        }
        for tuple_element in qTuples {
            try self._check_qubit(tuple_element)
            qubits.append(tuple_element)
        }
        try QuantumCircuit._check_dups(qubits)
        return self._attach(Barrier(qubits, self))
    }
}
