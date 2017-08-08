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

public final class InstructionSet {

    private var instructions: [Instruction] = []

    /**
     Add instruction to set.
     */
    public func add(_ instruction: Instruction) {
        self.instructions.append(instruction)
    }

    /**
     Invert all instructions
     */
    public func inverse() -> InstructionSet {
        for instruction in self.instructions {
            instruction.inverse()
        }
        return self
    }

    /**
     Add controls to all instructions.
     */
    public func q_if(_ qregs:[QuantumRegister]) -> InstructionSet {
        for instruction in self.instructions {
            instruction.q_if(qregs)
        }
        return self
    }

    /**
     Add classical control register to all instructions
     */
    public func c_if(_ c: ClassicalRegister, _ val: Int) throws -> InstructionSet {
        for instruction in self.instructions {
            try instruction.c_if(c, val)
        }
        return self
    }
}
