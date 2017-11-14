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
 Composite gate, a sequence of unitary gates.
 */
public class CompositeGate: Gate {

    private(set) var data: [Instruction] = []  // gate sequence defining the composite unitary
    private var inverse_flag = false

    public override init(_ name: String, _ params: [Double], _ qargs: [QuantumRegister], _ circuit: QuantumCircuit?) {
        if type(of: self) == CompositeGate.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs, circuit)
    }

    public override init(_ name: String, _ params: [Double], _ qargs: [QuantumRegisterTuple], _ circuit: QuantumCircuit?) {
        if type(of: self) == CompositeGate.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs, circuit)
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
    public func has_register(_ register: Register) throws -> Bool {
        try self.check_circuit()
        return self.circuit!.has_register(register)
    }

    /**
     Apply any modifiers of this gate to another composite.
     */
    public func _modifiers(_ gate: Gate) throws {
        if self.inverse_flag {
            gate.inverse()
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
     Attach barrier.
     */
    public func _attach(_ barrier: Barrier) -> Barrier {
        self.data.append(barrier)
        return barrier
    }

    /**
     Raise exception if q is not an argument or not qreg in circuit.
     */
    public func _check_qubit(_ qubit: QuantumRegisterTuple) throws {
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
        throw QISKitError.notQubitGate(qubit: qubit)
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
    public func _check_creg(_ register: ClassicalRegister) throws {
        try self.check_circuit()
        try self.circuit!._check_creg(register)
    }

    /**
     Invert this gate.
     */
    public override func inverse() -> Gate {
        var array:[Instruction] = []
        for gate in self.data.reversed() {
            array.append(gate.inverse())
        }
        self.data = array
        self.inverse_flag = !self.inverse_flag
        return self
    }

    /**
     Add controls to this gate.
     */
    public override func q_if(_ qregs:[QuantumRegister]) -> CompositeGate {
        var array:[Instruction] = []
        for gate in self.data {
            array.append(gate.q_if(qregs))
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

    private func append(_ gate: Gate) -> CompositeGate {
        self.data.append(gate)
        gate.circuit = self.circuit
        return self
    }
}
