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
 controlled-U3 gate.
 */
public final class Cu3Gate: Gate {

    public let instructionComponent: InstructionComponent

    fileprivate init(_ theta: Double,_ phi: Double,_ lam: Double, _ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("cu3", [theta,phi,lam], [ctl,tgt], circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> Cu3Gate {
        return Cu3Gate(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        let theta = self.params[0].format(15)
        let phi = self.params[1].format(15)
        let lam = self.params[2].format(15)
        return self._qasmif("\(name)(\(theta),\(phi),\(lam)) \(self.args[0].identifier),\(self.args[1].identifier)")
    }

    /**
     Invert this gate.
     */
    @discardableResult
    public func inverse() -> Cu3Gate {
        self.instructionComponent.params[0] = -self.instructionComponent.params[0]
        let phi = self.instructionComponent.params[1]
        self.instructionComponent.params[1] = -self.instructionComponent.params[2]
        self.instructionComponent.params[2] = -phi
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.cu3(self.params[0],self.params[1],self.params[2],self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     pply crz from ctl to tgt with angle theta.
     */
    @discardableResult
    public func cu3(_ theta: Double,_ phi: Double,_ lam: Double, _ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> Cu3Gate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(Cu3Gate(theta,phi,lam,ctl, tgt, self)) as! Cu3Gate
    }
}

extension CompositeGate {

    /**
     Apply crz from ctl to tgt with angle theta.
     */
    @discardableResult
    public func cu3(_ theta: Double,_ phi: Double,_ lam: Double, _ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> Cu3Gate {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(Cu3Gate(theta,phi,lam,ctl, tgt, self.circuit)) as! Cu3Gate
    }
}
