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

/*
Node for an OPENQASM integer.
This node has no children. The data is in the value field.
*/
@objc public final class NodeNNInt: Node {

    public let value: Int

    public init(value: Int) {
        self.value = value
    }
    
    public override var type: NodeType {
        return .N_INT
    }
    
    public override func qasm() -> String {
        let qasm: String = "\(value)"
        return qasm
    }
}
