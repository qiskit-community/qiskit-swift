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
Node for an OPENQASM reset statement.
children[0] is a primary node (id or indexedid)
*/

public final class NodeReset: Node {
    
    public let indexedid: Node?
 
    @objc public init(indexedid: Node?) {
        self.indexedid = indexedid
    }
    
    public override var type: NodeType {
        return .N_RESET
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let a = indexedid {
            _children.append(a)
        }
        return _children
    }

    public override func qasm(_ prec: Int) -> String {
        guard let iid = indexedid else {
            assertionFailure("Invalid NodeReset Operation")
            return ""
        }
        return "reset \(iid.qasm(prec));"
    }

}
