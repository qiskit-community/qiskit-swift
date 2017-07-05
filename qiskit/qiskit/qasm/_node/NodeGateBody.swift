//
//  NodeGateBody.swift
//  qiskit
//
//  Created by Joe Ligman on 6/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM custom gate body.
 children is a list of gate operation nodes.
 These are one of barrier, custom_unitary, U, or CX.
*/

@objc public final class NodeGateBody: Node {
    
    public var goplist: Node?
    
    public init(goplist: Node?) {
        super.init()
        self.goplist = goplist
    }
    
    public func calls() -> [String] {
        // Return a list of custom gate names in this gate body."""
        var _calls: [String] = []
        if let glist = goplist as? NodeGopList {
            if let gops = glist.gateops {
                for gop in gops {
                    if gop.type == .N_CUSTOMUNITARY {
                        _calls.append(gop.name)
                    }
                }
            }
        }
        return _calls
    }
 
    public override var type: NodeType {
        return .N_GATEBODY
    }
   
    public override var children: [Node] {
        if let glist = goplist as? NodeGopList {
            return glist.children
        }
        return []
    }
    
    public override func qasm() -> String {
        var qasms: [String] = []
        if let glist = goplist as? NodeGopList {
            qasms = glist.children.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: "\n")
    }
}
