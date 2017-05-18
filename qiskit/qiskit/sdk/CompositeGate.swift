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

    private var data: [Gate] = []  // gate sequence defining the composite unitary
    private var inverse_flag = false

    public override init(_ name: String, _ params: [Double], _ qargs: [QuantumRegister]) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs)
    }

    public override init(_ name: String, _ params: [Double], _ args: [QuantumRegisterTuple]) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, args)
    }

    public override var description: String {
        var text = ""
        for statement in self.data {
            text.append("\n\(statement.description);")
        }
        return text
    }

    /**
     Test if this gate's circuit has the register.
     */
    public func has_register(register: Register) throws -> Bool {
        try self.check_circuit()
        return self.circuit!.has_register(register)
    }

    /**
     Apply any modifiers of this gate to another composite.
     */
    public override func _modifiers(_ gate: Gate) throws {
        if self.inverse_flag {
            _ = try gate.inverse()
        }
        try super._modifiers(gate)
    }

    /**
     Attach gate.
     */
    public func _attach(_ gate: Gate) -> Gate {
        self.data.append(gate)
        return gate
    }

    /**
     Raise exception if q is not an argument or not qreg in circuit.
     */
    public func _check_qubit(qubit: QuantumRegisterTuple) throws {
        try self.check_circuit()
        try self.circuit!._check_qubit(qubit)
        for arg in self.args {
            if let tuple = arg as? QuantumRegisterTuple {
                if tuple.register.name == qubit.register.name &&
                    tuple.index == qubit.index {
                    return
                }
            }
        }
        throw  QISKitException.notqubitgate(qubit: qubit)
    }

    /**
     Raise exception if quantum register is not in this gate's circuit.
     */
    public func _check_qreg(_ register: QuantumRegister) throws {
        try self.check_circuit()
        try self.circuit!._check_qreg(register)
    }

    /**
     Raise exception if classical register is not in this gate's circuit.
     */
    public func _check_creg(register: ClassicalRegister) throws {
        try self.check_circuit()
        try self.circuit!._check_creg(register)
    }

    /**
     Raise exception if list of qubits contains duplicates.
     */
    public func _check_dups(qubits: [QuantumRegisterTuple]) throws {
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

    /**
     Invert this gate.
     */
    public override func inverse() throws -> Gate {
        var array:[Gate] = []
        for gate in self.data.reversed() {
            array.append(try gate.inverse())
        }
        self.data = array
        self.inverse_flag = !self.inverse_flag
        return self
    }

    /**
     Add controls to this gate.
     */
    public func q_if(qregs:[QuantumRegister]) throws -> CompositeGate {
        var array:[Gate] = []
        for gate in self.data {
            array.append(try gate.q_if(qregs))
        }
        self.data = array
        return self
    }

    /**
     Add classical control register.
     */
    public override func c_if(_ c: ClassicalRegister, _ val: Int) throws -> CompositeGate {
        var array:[Gate] = []
        for gate in self.data {
            array.append(try gate.c_if(c, val) as! Gate)
        }
        self.data = array
        return self
    }

    public func append(_ gate: Gate) -> CompositeGate {
        self.data.append(gate)
        gate.circuit = self.circuit
        return self
    }

    public func append(contentsOf: [Gate]) -> CompositeGate {
        self.data.append(contentsOf: contentsOf)
        for gate in contentsOf {
            gate.circuit = self.circuit
        }
        return self
    }

    public static func += (left: inout CompositeGate, right: Gate) {
        let _ = left.append(right)
    }
}
