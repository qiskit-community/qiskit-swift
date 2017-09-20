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
Node for an OPENQASM expression list.
children are expression nodes.
*/
public final class NodeExpressionList: Node {

    public private(set) var expressionList: [Node]? = nil
    
    @objc public init(expression: Node?) {
        super.init()
        if let exp = expression {
            self.expressionList = [exp]
        }
    }

    @objc public func addExpression(exp: Node) {
        expressionList?.insert(exp, at: 0)
    }
    
    public override var type: NodeType {
        return .N_EXPRESSIONLIST
    }
    
    public override var children: [Node] {
        return (expressionList != nil) ? expressionList! : []
    }
    
    public override func qasm(_ prec: Int) -> String {
        var qasms: [String] = []
        if let elist = expressionList  {
            for node in elist {
                qasms.append(node.qasm(prec))
            }
        }
        return qasms.joined(separator: ",")
    }
}
