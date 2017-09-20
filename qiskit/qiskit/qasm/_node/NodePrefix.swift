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
Node for an OPENQASM prefix expression.
children[0] is a prefix string such as '-'.
children[1] is an expression node.
*/
public final class NodePrefix: Node, NodeRealValueProtocol {

    public let op: String
    public let _children: [Node]

    @objc public init(op: String, children: [Node]) {
        self.op = op
        self._children = children
    }
    
    public override var type: NodeType {
        return .N_PREFIX
    }
    
    public override var children: [Node] {
        return _children
    }
    
    public override func qasm(_ prec: Int) -> String {
        let operand = self._children[0]
        if operand.type == .N_BINARYOP {
            return "\(op) (\(operand.qasm(prec)))"
        }
        return "\(op)\(operand.qasm(prec))"
    }

    public func real(_ nested_scope: [[String:NodeRealValueProtocol]]?) throws -> Double {
        let operation = self.op
        guard let operand = self._children[0] as? NodeRealValueProtocol else {
            throw QasmException.errorPrefix(qasm: self.qasm(15))
        }
        let expr = try operand.real(nested_scope)
        if operation == "+" {
            return expr
        }
        if operation == "-" {
            return -expr
        }
        throw QasmException.errorPrefix(qasm: self.qasm(15))
    }
}
