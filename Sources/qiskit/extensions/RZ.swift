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
 rotation around the z-axis
 */
public final class RZGate: Gate {

    public var instructionComponent: InstructionComponent

    fileprivate init(_ theta: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("rz", [theta], [qubit], circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> Instruction {
        return RZGate(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        let theta = self.params[0].format(15)
        return self._qasmif("\(name)(\(theta)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     ry(theta)^dagger = ry(-theta)
     */
    public func inverse() -> Instruction {
        self.instructionComponent.params[0] = -self.instructionComponent.params[0]
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.rz(self.params[0], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply rz to q.
     */
    public func rz(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.rz(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply rz to q.
     */
    @discardableResult
    public func rz(_ theta: Double, _ q: QuantumRegisterTuple) throws -> RZGate {
        try  self._check_qubit(q)
        return self._attach(RZGate(theta, q, self)) as! RZGate
    }
}

extension CompositeGate {

    /**
     Apply rz to q.
     */
    public func rz(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.rz(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply rz to q.
     */
    @discardableResult
    public func rz(_ theta: Double, _ q: QuantumRegisterTuple) throws -> RZGate {
        try  self._check_qubit(q)
        return self._attach(RZGate(theta, q, self.circuit)) as! RZGate
    }
}

