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
 Qubit reset
 */
public final class Reset: Instruction {

    public init(_ qreg: QuantumRegister, _ circuit: QuantumCircuit? = nil) {
        super.init("reset", [], [qreg], circuit)
    }

    public init(_ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) {
        super.init("reset", [], [qubit], circuit)
    }

    public override var description: String {
        return "\(name) \(self.args[0].identifier)"
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public func reapply(circ: QuantumCircuit) {
       // self._modifiers(circ.reset(self.arg[0]))
    }
}
