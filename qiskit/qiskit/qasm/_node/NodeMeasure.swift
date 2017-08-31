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
 Node for an OPENQASM measure statement.
 children[0] is a primary node (id or indexedid)
 children[1] is a primary node (id or indexedid)
 */
@objc public final class NodeMeasure: Node {

    public let arg1: Node?
    public let arg2: Node?
    
    public init(arg1: Node?, arg2: Node?) {
        self.arg1 = arg1
        self.arg2 = arg2
    }
    
    public override var type: NodeType {
        return .N_MEASURE
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let a1 = arg1 {
            _children.append(a1)
        }
        if let a2 = arg2 {
            _children.append(a2)
        }
        return _children
    }
    
    public override func qasm(_ prec: Int) -> String {
        guard let a1 = arg1 else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        guard let a2 = arg2 else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        return "measure \(a1.qasm(prec)) -> \(a2.qasm(prec));"
    }
}
