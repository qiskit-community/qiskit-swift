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
 Two-pulse single qubit gate
 */
public final class U3Gate: Gate {

    public let instructionComponent: InstructionComponent

    fileprivate init(_ theta: Double, _ phi: Double, _ lam: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("u3", [theta,phi,lam], [qubit], circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> U3Gate {
        return U3Gate(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        let theta = self.params[0].format(15)
        let phi = self.params[1].format(15)
        let lam = self.params[2].format(15)
        return self._qasmif("\(name)(\(theta),\(phi),\(lam)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     u3(theta, phi, lamb)^dagger = u3(-theta, -lam, -phi)
     */
    @discardableResult
    public func inverse() -> U3Gate {
        self.instructionComponent.params[0] = -self.instructionComponent.params[0]
        let phi = self.params[1]
        self.instructionComponent.params[1] = -self.instructionComponent.params[2]
        self.instructionComponent.params[2] = -phi
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.u3(self.params[0], self.params[1],self.params[2], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply u3 q.
     */
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u3(theta, phi, lam, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u3 q.
     */
    @discardableResult
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegisterTuple) throws -> U3Gate {
        try  self._check_qubit(q)
        return self._attach(U3Gate(theta, phi, lam, q, self)) as! U3Gate
    }
}

extension CompositeGate {

    /**
     Apply u3 q.
     */
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u3(theta, phi, lam, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u3 q.
     */
    @discardableResult
    public func u3(_ theta: Double, _ phi: Double, _ lam: Double, _ q: QuantumRegisterTuple) throws -> U3Gate {
        try  self._check_qubit(q)
        return self._attach(U3Gate(theta, phi, lam, q, self.circuit)) as! U3Gate
    }
}
