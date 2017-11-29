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
 Generic quantum computer instruction.
 */
public protocol Instruction: CustomStringConvertible {

    var instructionComponent: InstructionComponent { get }
    func copy() -> Instruction
    @discardableResult
    func inverse() -> Instruction
    func reapply(_ circ: QuantumCircuit) throws
}

extension Instruction {

    var name: String {
        return instructionComponent.name
    }

    var params: [Double] {
        return instructionComponent.params
    }

    var args: [RegisterArgument] {
        return instructionComponent.args
    }

    var circuit: QuantumCircuit {
        return instructionComponent.circuit
    }

    public var qasm: String {
        return self.description
    }

    /**
     Apply any modifiers of this instruction to another one.
     */
    public func _modifiers(_ instruction: Instruction) throws {
        try self.instructionComponent._modifiers(instruction)
    }

    /**
     Print an if statement if needed.
     */
    public func _qasmif(_ string: String) -> String {
        return self.instructionComponent._qasmif(string)
    }

    @discardableResult
    public func c_if(_ classical: ClassicalRegister, _ val: Int) throws -> Instruction {
        try self.instructionComponent.c_if(classical,val)
        return self
    }

    @discardableResult
    public func q_if(_ qregs:[QuantumRegister]) -> Instruction {
        preconditionFailure("q_if not implemented")
    }
}
