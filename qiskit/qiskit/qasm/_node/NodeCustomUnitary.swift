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
 Node for an OPENQASM custom gate statement.

children[0] is an id node.
children[1] is an exp_list (if len==3) or primary_list.
children[2], if present, is a primary_list.

Has properties:
.id = id node
.name = gate name string
.arguments = None or exp_list node
.bitlist = primary_list node
*/
@objc public final class NodeCustomUnitary: Node {
    
    public let identifier: Node?
    public let arguments: Node?
    public let bitlist: Node?
    public private(set) var _name: String = ""

    public init(identifier: Node?, arguments: Node?, bitlist: Node?) {
        self.identifier = identifier     // id
        self.arguments = arguments   // anylist
        self.bitlist = bitlist   // explist
    
         if let _id = self.identifier as? NodeId {
            _name = _id._name
        }
    }
    
    public override var type: NodeType {
        return .N_CUSTOMUNITARY
    }

    public override var name: String {
        return _name
    }

    public override func qasm(_ prec: Int) -> String {
        var qasm = "\(self.name)"
        if let args = self.arguments {
            qasm += " (" + args.qasm(prec) + ")"
        }
        if let bits = self.bitlist {
            qasm += " \(bits.qasm(prec));"
        }
        return qasm
    }
}
