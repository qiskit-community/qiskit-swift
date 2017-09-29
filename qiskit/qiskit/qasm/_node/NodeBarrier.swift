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
 class Barrier(Node):
 Node for an OPENQASM barrier statement.
 children[0] is a primarylist node.
 */
public final class NodeBarrier: Node {

    public let list: Node?
    
    @objc public init(list: Node?) {
        self.list = list
    }

    public override var type: NodeType {
        return .N_BARRIER
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let al = list {
            _children.append(al)
        }
        return _children
    }

    
    public override func qasm(_ prec: Int) -> String {
        var qasm: String = "barrier"
        guard let l = list else {
            assertionFailure("Invalid NodeBarrier Operation")
            return ""
        }
        qasm += " \(l.qasm(prec));"
        return qasm
    }
}