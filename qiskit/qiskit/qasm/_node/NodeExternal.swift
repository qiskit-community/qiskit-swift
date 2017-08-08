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
 Node for an OPENQASM external function.
 children[0] is an id node with the name of the function.
 children[1] is an expression node.
 */
@objc public final class NodeExternal: Node {

    public static let externalFunctions = ["sin", "cos", "tan", "exp", "ln", "sqrt"]

    public let operation: String
    public let expression: Node?
    
    public init(operation: String, expression: Node?) {
        self.operation = operation
        self.expression = expression
    }
    
    public override var type: NodeType {
        return .N_EXTERNAL
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let exp = expression {
            _children.append(exp)
        }
        return _children
    }

    public override func qasm() -> String {
        var qasm = operation
        if let exp = expression {
            qasm += "( \(exp.qasm()) )"
        }
        return qasm
    }

}
