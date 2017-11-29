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
 Quantum computer instruction component.
 */
public final class InstructionComponent {

    let name: String
    var params: [Double]
    let args: [RegisterArgument]
    unowned var circuit: QuantumCircuit
    private var control: (ClassicalRegister, Int)? = nil

    init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit) {
        self.name = name
        self.params = params
        self.args = args
        self.circuit = circuit
    }

    /**
     Add classical control on register classical and value val.
     */
    func c_if(_ classical: ClassicalRegister, _ val: Int) throws {
        if val < 0 {
            throw QISKitError.controlValueNegative
        }
        self.control = (classical, val)
    }

    /**
     Apply any modifiers of this instruction to another one.
     */
    func _modifiers(_ instruction: Instruction) throws {
        if self.control != nil {
            if !self.circuit.has_register(self.control!.0) {
                throw QISKitError.controlRegNotFound(name: self.control!.0.name)
            }
            try instruction.c_if(self.control!.0, self.control!.1)
        }
    }

    /**
     Print an if statement if needed.
     */
    func _qasmif(_ string: String) -> String {
        if self.control == nil {
            return string
        }
        return "if(\(self.control!.0.name)==\(self.control!.1)) \(string)"
    }
}
