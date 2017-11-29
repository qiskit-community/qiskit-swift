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
 Pauli Y (bit-phase-flip) gate.
 */
public final class YGate: Gate {

    public var instructionComponent: InstructionComponent

    fileprivate init(_ qreg: QuantumRegisterTuple, _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("y", [], [qreg], circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> Instruction {
        return YGate(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     */
    public func inverse() -> Instruction {
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.y(self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply y to q.
     */
    public func y(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.y(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply y to q.
     */
    @discardableResult
    public func y(_ q: QuantumRegisterTuple) throws -> YGate {
        try  self._check_qubit(q)
        return self._attach(YGate(q, self)) as! YGate
    }
}

extension CompositeGate {

    /**
     Apply y to q.
     */
    public func y(_ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.y(QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply y to q.
     */
    @discardableResult
    public func y(_ q: QuantumRegisterTuple) throws -> YGate {
        try  self._check_qubit(q)
        return self._attach(YGate(q, self.circuit)) as! YGate
    }
}
