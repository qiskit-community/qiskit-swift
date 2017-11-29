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
 Fundamental controlled-NOT gate.
 */
public final class CXBase: Gate {

    public var instructionComponent: InstructionComponent

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent("CX", [], [ctl,tgt], circuit)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
    }

    public func copy() -> Instruction {
        return CXBase(self.name, self.params, self.args, self.circuit)
    }

    public var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
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
        try self._modifiers(circ.cx_base(self.args[0] as! QuantumRegisterTuple, self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply CX from ctl, tgt.
     */
    @discardableResult
    public func cx_base(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CXBase {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CXBase(ctl, tgt, self)) as! CXBase
    }
}

extension CompositeGate {

    /**
     Apply CX from ctl, tgt.
     */
    @discardableResult
    public func cx_base(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> CXBase {
        try  self._check_qubit(ctl)
        try self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return self._attach(CXBase(ctl, tgt, self.circuit)) as! CXBase
    }
}
