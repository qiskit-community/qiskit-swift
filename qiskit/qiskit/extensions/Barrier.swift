//
//  Barrier.swift
//  qiskit
//
//  Created by Manoel Marques on 4/12/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Quantum Barrier class
 */
public final class Barrier: Instruction {

    fileprivate init(_ qregs: [QuantumRegister], _ circuit: QuantumCircuit) {
        super.init("barrier", [], qregs, circuit)
    }

    fileprivate init(_ qargs: [QuantumRegisterTuple], _ circuit: QuantumCircuit) {
        super.init("barrier", [], qargs, circuit)
    }

    fileprivate init(_ qregs: [QuantumRegister], _ gate: CompositeGate) {
        super.init("barrier", [], qregs, gate.circuit)
    }

    fileprivate init(_ qargs: [QuantumRegisterTuple], _ gate: CompositeGate) {
        super.init("barrier", [], qargs, gate.circuit)
    }

    public override var description: String {
        var text = "barrier "
        let array = self.args.map {$0.identifier}
        text.append(array.joined(separator: ","))
        return text
    }

    /**
     Special case. Return self.
     */
    public override func inverse() -> Instruction {
        return self
    }

    /**
    Reapply this instruction to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
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
            for register in self.regs {
                if register is QuantumRegister {
                    registers.append(register as! QuantumRegister)
                }
            }
            if registers.isEmpty {
                throw QISKitException.noarguments
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
            for reg in self.regs {
                if let register = reg as? QuantumRegister {
                    registers.append(register)
                }
            }
            if registers.isEmpty {
                throw QISKitException.noarguments
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
            throw QISKitException.noarguments
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
            throw QISKitException.noarguments
        }
        var qubits: [QuantumRegisterTuple] = []
        if qTuples.isEmpty { //TODO: implement this for all single qubit gates
            throw QISKitException.noarguments
        }
        for tuple_element in qTuples {
            try self._check_qubit(tuple_element)
            qubits.append(tuple_element)
        }
        try QuantumCircuit._check_dups(qubits)
        return self._attach(Barrier(qubits, self))
    }
}
