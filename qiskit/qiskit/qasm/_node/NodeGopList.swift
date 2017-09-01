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

@objc public final class NodeGopList: Node {

    public private(set) var gateops: [Node]?
    
    public init(gateop: Node?) {
        super.init()
        if let gop = gateop {
            self.gateops = [gop]
        }
    }
    
    public func addIdentifier(gateop: Node) {
        gateops?.append(gateop)
    }
    
    public func calls() -> [String] {
        // Return a list of custom gate names in this gate body."""
        var _calls: [String] = []
        if let gops = self.gateops {
            for gop in gops {
                if gop.type == .N_CUSTOMUNITARY {
                    _calls.append(gop.name)
                }
            }
        }
        return _calls
    }
    
    public override var type: NodeType {
        return .N_GATEOPLIST
    }
    
    public override var children: [Node] {
        return (gateops != nil) ? gateops! : []
    }
    
    public override func qasm(_ prec: Int) -> String {
        var qasms: [String] = []
        if let list = gateops {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm(prec)
            })
        }
        return qasms.joined(separator: "\n")
    }
}

