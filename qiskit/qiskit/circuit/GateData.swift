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
 "opaque" = True or False
 "n_args" = number of real parameters
 "n_bits" = number of qubits
 "args"   = list of parameter names
 "bits"   = list of qubit names
 "body"   = GateBody AST node
 */

final class GateData {

    let opaque: Bool
    let n_args: Int
    let n_bits: Int
    let args: [String]
    let bits: [String]
    let body: NodeGateBody?

    init(_ opaque: Bool, _ n_args: Int, _ n_bits: Int, _ args: [String], _ bits: [String], _ body: NodeGateBody?) {
        self.opaque = opaque
        self.n_args = n_args
        self.n_bits = n_bits
        self.args = args
        self.bits = bits
        self.body = body
    }
}
