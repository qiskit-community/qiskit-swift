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
 Node for an OPENQASM opaque gate declaration.
 children[0] is an id node.
 If len(children) is 3, children[1] is an expressionlist node,
 and children[2] is an idlist node.
 Otherwise, children[1] is an idlist node.
 */
public final class NodeOpaque: Node {

    public let identifier: Node?
    public let arguments: Node?
    public let bitlist: Node?
    
    public private(set) var _name: String = ""
    public private(set) var line: Int = 0
    public private(set) var file: String = ""
    public private(set) var index: Int = 0
    
    public var n_args: Int {
        get{
            return arguments?.children.count ?? 0
        }
    }
    
    public var n_bits: Int {
        get {
            return bitlist?.children.count ?? 0
        }
    }

    
    @objc public init(identifier: Node?, arguments: Node?, bitlist: Node?) {
        self.identifier = identifier
        self.arguments = arguments
        self.bitlist = bitlist
        if let _id = self.identifier as? NodeId{
            // Name of the qreg
            self._name = _id.name
            // Source line number
            self.line = _id.line
            // Source file name
            self.file = _id.file
            // Size of the register
            self.index = _id.index
        }
    }
    
    public override var type: NodeType {
        return .N_OPAQUE
    }
   
    public override var name: String {
        return _name
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let ident = identifier {
            _children.append(ident)
        }
        if let l1 = arguments {
            _children.append(l1)
        }
        if let l2 = bitlist {
            _children.append(l2)
        }
        return _children
    }
    

    public override func qasm(_ prec: Int) -> String {
        var qasm: String = "opaque"
        
        guard let ident = identifier else {
            assertionFailure("Invalid NodeOpaque Operation")
            return ""
        }

        guard let l1 = arguments else {
            assertionFailure("Invalid NodeOpaque Operation")
            return ""
        }
        
        if let l2 = bitlist {
            qasm += " \(ident.qasm(prec)) ( \(l1.qasm(prec)) ) \(l2.qasm(prec));"
        } else {
            qasm += " \(ident.qasm(prec)) \(l1.qasm(prec));"
        }
        
        return qasm
    }
}
