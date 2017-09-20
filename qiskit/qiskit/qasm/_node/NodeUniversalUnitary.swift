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
Node for an OPENQASM U statement.
children[0] is an expressionlist node.
children[1] is a primary node (id or indexedid).
*/
public final class NodeUniversalUnitary: Node {

    public let explist: Node?
    public let indexedid: Node?
    
    @objc public init(explist: Node?, indexedid: Node?) {
        self.explist = explist
        self.indexedid = indexedid
    }
    
    public override var type: NodeType {
        return .N_UNIVERSALUNITARY
    }

    public override var children: [Node] {
        var _children: [Node] = []
        if let el = explist {
            _children.append(el)
        }
        if let iid = indexedid {
            _children.append(iid)
        }
        return _children
    }

    public override func qasm(_ prec: Int) -> String {
        guard let el = explist else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
        
        guard let iid = indexedid else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
        return "U (\(el.qasm(prec))) \(iid.qasm(prec));"
    }
}
