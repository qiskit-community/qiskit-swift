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
 Toffoli gate.
 */
public final class ToffoliGate: Gate {

    public let instructionComponent: InstructionComponent

    fileprivate init(_ ctl1:QuantumRegisterTuple, _ ctl2:QuantumRegisterTuple, _ tgt:QuantumRegisterTuple, _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("ccx", [], [ctl1, ctl2, tgt], circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> ToffoliGate {
        return ToffoliGate(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        return self._qasmif("\(self.name) \(self.args[0].identifier),\(self.args[1].identifier),\(self.args[2].identifier)")
    }

    /**
     Invert this gate.
     */
    @discardableResult
    public func inverse() -> ToffoliGate {
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.ccx(self.args[0] as! QuantumRegisterTuple,
                                     self.args[1] as! QuantumRegisterTuple,
                                     self.args[2] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply Toffoli to circuit.
     */
    @discardableResult
    public func ccx(_ ctl1: QuantumRegisterTuple, _ ctl2: QuantumRegisterTuple, _ tgt:QuantumRegisterTuple) throws -> ToffoliGate {
        try  self._check_qubit(ctl1)
        try  self._check_qubit(ctl2)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl1, ctl2, tgt])
        return self._attach(ToffoliGate(ctl1, ctl2, tgt, self)) as! ToffoliGate
    }
}

extension CompositeGate {

    /**
     Apply Toffoli to circuit.
     */
    @discardableResult
    public func ccx(_ ctl1: QuantumRegisterTuple, _ ctl2: QuantumRegisterTuple, _ tgt:QuantumRegisterTuple) throws -> ToffoliGate {
        try  self._check_qubit(ctl1)
        try  self._check_qubit(ctl2)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl1, ctl2, tgt])
        return self._attach(ToffoliGate(ctl1, ctl2, tgt, self.circuit)) as! ToffoliGate
    }
}
