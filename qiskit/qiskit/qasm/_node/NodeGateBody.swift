//
//  NodeGateBody.swift
//  qiskit
//
//  Created by Joe Ligman on 6/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGateBody: Node {
    
    public var goplist: Node?
    
    public func calls() -> [String] {
        return []
    }
    
    public override var type: NodeType {
        return .N_GATEBODY
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let gplist = goplist {
            _children.append(gplist)
        }
        return _children
    }

    public func updateNode(goplist: Node?) {
        self.goplist = goplist
    }
    
    public override func qasm() -> String {
        if let glist = goplist {
            return "\(glist.qasm())"
        }
        return ""
    }
}
