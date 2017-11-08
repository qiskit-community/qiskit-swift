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
public final class NodeExternal: Node, NodeRealValueProtocol {

    public static let externalFunctions = ["sin", "cos", "tan", "exp", "ln", "sqrt"]

    public let operation: String
    public let expression: Node
    
    @objc public init(operation: String, expression: Node) {
        self.operation = operation
        self.expression = expression
    }
    
    public override var type: NodeType {
        return .N_EXTERNAL
    }
    
    public override var children: [Node] {
        return [self.expression]
    }

    public override func qasm(_ prec: Int) -> String {
        var qasm = self.operation
        qasm += "( \(self.expression.qasm(prec)) )"
        return qasm
    }

    public func real(_ nested_scope: [[String:NodeRealValueProtocol]]?) throws -> Double {
        if let expr = self.expression as? NodeRealValueProtocol {
            let arg = try expr.real(nested_scope)
            if self.operation == "sin" {
                return sin(arg)
            }
            if self.operation == "cos" {
                return cos(arg)
            }
            if self.operation == "tan" {
                return tan(arg)
            }
            if self.operation == "exp" {
                return exp(arg)
            }
            if self.operation == "ln" {
                return log(arg)
            }
            if self.operation == "sqrt" {
                return sqrt(arg)
            }
        }
        throw QasmException.errorExternal(qasm: self.qasm(15))
    }
}
