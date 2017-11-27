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
 SWAP Gate.
 */
public final class SwapGate: Gate {

    fileprivate init(_ ctl: QuantumRegisterTuple,_ tgt: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        super.init("swap", [], [ctl,tgt], circuit)
    }

    override private init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit?) {
        super.init(name, params, args, circuit)
    }

    override public func copy() -> Instruction {
        return SwapGate(self.name, self.params, self.args, self.circuit)
    }

    public override var description: String {
        return self._qasmif("\(name) \(self.args[0].identifier),\(self.args[1].identifier)")
    }

    /**
     Invert this gate.
     */
    public override func inverse() -> Gate {
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.swap(self.args[0] as! QuantumRegisterTuple,
                                     self.args[1] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply SWAP from ctl to tgt.
     */
    @discardableResult
    public func swap(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> SwapGate {
        try  self._check_qubit(ctl)
        try  self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return try self._attach(SwapGate(ctl, tgt, self)) as! SwapGate
    }
}

extension CompositeGate {

    /**
     Apply SWAP from ctl to tgt.
     */
    @discardableResult
    public func swap(_ ctl: QuantumRegisterTuple, _ tgt: QuantumRegisterTuple) throws -> SwapGate {
        try  self._check_qubit(ctl)
        try  self._check_qubit(tgt)
        try QuantumCircuit._check_dups([ctl, tgt])
        return try self._attach(SwapGate(ctl, tgt, self.circuit)) as! SwapGate
    }
}
