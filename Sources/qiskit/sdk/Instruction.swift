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
public class Instruction: CustomStringConvertible {

    let name: String
    var params: [Double]
    let args: [RegisterArgument]
    weak var circuit: QuantumCircuit? = nil
    private var control: (ClassicalRegister, Int)? = nil

    public var description: String {
        preconditionFailure("description not implemented")
    }

    public var qasm: String {
        return self.description
    }

    /**
     Create a new instruction.
     
     - parameter name: instruction name string
     - parameter param: list of real parameters
     - parameter arg: list InstructionArgument
     */
    public init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit?) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = name
        self.params = params
        self.args = args
        self.circuit = circuit
    }

    /**
     Raise exception if self.circuit is nil.
     */
    public func check_circuit() throws {
        if self.circuit == nil {
            throw QISKitError.intructionCircuitNil
        }
    }

    /**
     Add classical control on register classical and value val.
     */
    @discardableResult
    public func c_if(_ classical: ClassicalRegister, _ val: Int) throws -> Instruction {
        if val < 0 {
            throw QISKitError.controlValueNegative
        }
        self.control = (classical, val)
        return self
    }

    @discardableResult
    public func q_if(_ qregs:[QuantumRegister]) -> Instruction {
        preconditionFailure("q_if not implemented")
    }

    /**
     Apply any modifiers of this instruction to another one.
     */
    public func _modifiers(_ instruction: Instruction) throws {
        if self.control != nil {
            try self.check_circuit()
            if !instruction.circuit!.has_register(self.control!.0) {
                throw QISKitError.controlRegNotFound(name: self.control!.0.name)
            }
            try instruction.c_if(self.control!.0, self.control!.1)
        }
    }

    /**
     Print an if statement if needed.
     */
    public func _qasmif(_ string: String) -> String {
        if self.control == nil {
            return string
        }
        return "if(\(self.control!.0.name)==\(self.control!.1)) \(string)"
    }

    @discardableResult
    public func inverse() -> Instruction {
        preconditionFailure("inverse not implemented")
    }

    public func reapply(_ circ: QuantumCircuit) throws {
        preconditionFailure("reapply not implemented")
    }
}
