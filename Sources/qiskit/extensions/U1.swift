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
 Diagonal single qubit gate
 */
public final class U1Gate: Gate {

    fileprivate init(_ theta: Double, _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("u1", [theta], [qubit], circuit)
    }

    public override var description: String {
        let theta = self.params[0].format(15)
        return self._qasmif("\(name)(\(theta)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     */
    @discardableResult
    public override func inverse() -> Gate {
        self.params[0] = -self.params[0]
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.u1(self.params[0], self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply u1 with angle theta to q.
     */
    public func u1(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u1(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u1 with angle theta to q.
     */
    @discardableResult
    public func u1(_ theta: Double, _ q: QuantumRegisterTuple) throws -> U1Gate {
        try  self._check_qubit(q)
        return self._attach(U1Gate(theta, q, self)) as! U1Gate
    }
}

extension CompositeGate {

    /**
     Apply u1 with angle theta to q.
     */
    public func u1(_ theta: Double, _ q: QuantumRegister) throws -> InstructionSet {
        let gs = InstructionSet()
        for j in 0..<q.size {
            gs.add(try self.u1(theta, QuantumRegisterTuple(q,j)))
        }
        return gs
    }

    /**
     Apply u1 with angle theta to q.
     */
    @discardableResult
    public func u1(_ theta: Double, _ q: QuantumRegisterTuple) throws -> U1Gate {
        try  self._check_qubit(q)
        return self._attach(U1Gate(theta, q, self.circuit)) as! U1Gate
    }
}
