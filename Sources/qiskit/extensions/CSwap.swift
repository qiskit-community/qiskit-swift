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
 Fredkin gate. Controlled-SWAP.
 */
public final class FredkinGate: CompositeGate, CopyableInstruction {

    public let instructionComponent: InstructionComponent
    public let compositeGateComponent: CompositeGateComponent

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt1: QuantumRegisterTuple, _ tgt2: QuantumRegisterTuple, _ circuit: QuantumCircuit) throws {
        self.instructionComponent = InstructionComponent("fredkin", [], [ctl,tgt1, tgt2], circuit)
        self.compositeGateComponent = CompositeGateComponent()
        try self.cx(tgt2,tgt1)
        try self.ccx(ctl,tgt1,tgt2)
        try self.cx(tgt2,tgt1)
    }

    private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit, _ compositeGateComponent: CompositeGateComponent) {
        self.instructionComponent = InstructionComponent(name, params, args, circuit)
        self.compositeGateComponent = compositeGateComponent
    }

    func copy(_ c: QuantumCircuit) -> Instruction {
        return FredkinGate(self.name, self.params, self.args, c,self.compositeGateComponent.copy(c))
    }

    public var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.cswap(self.args[0] as! QuantumRegisterTuple,
                                     self.args[1] as! QuantumRegisterTuple,
                                     self.args[2] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply FredkinGate to circuit.
     */
    @discardableResult
    public func cswap(_ ctl: QuantumRegisterTuple, _ tgt1: QuantumRegisterTuple, _ tgt2:QuantumRegisterTuple) throws -> FredkinGate {
        try  self._check_qubit(ctl)
        try  self._check_qubit(tgt1)
        try self._check_qubit(tgt2)
        try QuantumCircuit._check_dups([ctl, tgt1, tgt2])
        return try self._attach(FredkinGate(ctl, tgt1, tgt2, self)) as! FredkinGate
    }
}

extension CompositeGate {

    /**
     Apply FredkinGate to circuit.
     */
    @discardableResult
    public func cswap(_ ctl: QuantumRegisterTuple, _ tgt1: QuantumRegisterTuple, _ tgt2:QuantumRegisterTuple) throws -> FredkinGate {
        try  self._check_qubit(ctl)
        try  self._check_qubit(tgt1)
        try self._check_qubit(tgt2)
        try QuantumCircuit._check_dups([ctl, tgt1, tgt2])
        return try self._attach(FredkinGate(ctl, tgt1, tgt2, self.circuit)) as! FredkinGate
    }
}
