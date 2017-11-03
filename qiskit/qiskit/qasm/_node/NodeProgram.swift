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
Node for an OPENQASM program.
children is a list of nodes (statements).
*/
public final class NodeProgram: Node  {

    public private(set) var statements: [Node]? = nil
    
    @objc public init(statement: Node?) {
        if let stmt = statement {
            self.statements = [stmt]
        }
    }
    
    @objc public func addStatement(statement: Node) {
        statements?.append(statement)
    }
    
    public override var type: NodeType {
        return .N_PROGRAM
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let stmnts = statements {
            for s in stmnts {
                _children.append(s)
            }
        }
        return _children
    }
    
    public override func qasm(_ prec: Int) -> String {
        
        var qasms: [String] = []
        if let stmt = statements {
            qasms += stmt.flatMap({ (node: Node) -> String in
                                    return node.qasm(prec)
                                    })
        }
        return qasms.joined(separator: "\n")
    }
}
