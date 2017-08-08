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
 Node for an OPENQASM idlist.
 children is a list of id nodes.
 */
@objc public final class NodeIdList: Node {
    
    public private(set) var identifiers: [Node]?

    public init(identifier: Node?) {
        super.init()
        if let ident = identifier {
            self.identifiers = [ident]
        }
    }
    
    public func addIdentifier(identifier: Node) {
        identifiers?.append(identifier)
    }
    
    public override var type: NodeType {
        return .N_IDLIST
    }
    
    public override var children: [Node] {
        return (identifiers != nil) ? identifiers! : []
    }
    
    public override func qasm() -> String {
        var qasms: [String] = []
        if let list = identifiers {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: ",")
    }
}

