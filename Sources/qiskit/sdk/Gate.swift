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
 User Defined Gate class
 */
public class Gate: Instruction {

    init(_ name: String, _ params: [Double], _ args: [QuantumRegister], _ circuit: QuantumCircuit?) {
        if type(of: self) == Gate.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, args, circuit)
    }

    init(_ name: String, _ params: [Double], _ qargs: [QuantumRegisterTuple], _ circuit: QuantumCircuit?) {
        if type(of: self) == Gate.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs, circuit)
    }

    override init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit?) {
        super.init(name, params, args, circuit)
    }

    /**
     Invert this gate.
     */
    @discardableResult
    public override func inverse() -> Gate {
        preconditionFailure("inverse not implemented")
    }

    /**
     Add controls to this gate.
     */
    public override func q_if(_ qregs:[QuantumRegister]) -> Gate {
        preconditionFailure("q_if not implemented")
    }
}
