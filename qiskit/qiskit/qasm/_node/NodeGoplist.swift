//
//  NodeGoplist.swift
//  qiskit
//
//  Created by Joe Ligman on 6/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGoplist: Node {
    
    public private(set) var barriers: [Node]?
    public private(set) var uops: [Node]?

    public init(barrier: Node, idlist: Node) {
        (barrier as! NodeBarrier).updateNode(anylist: idlist)
    }

    public init(uop: Node) {
        uops = [uop]
    }

    public func addBarrierIdlist(barrier: Node, idlist: Node) {
        (barrier as! NodeBarrier).updateNode(anylist: idlist)
        barriers?.append(barrier)
    }
    
    public func addUop(uop: Node) {
        uops?.append(uop)
    }
    
    public override var type: NodeType {
        return .N_GOPLIST
    }
    
    public override func qasm() -> String {
        
        var qasms: [String] = []
        if let bl = barriers {
            for child in bl {
                qasms.append(child.qasm())
            }
        }
        if let ups = uops {
            for us in ups {
                qasms.append(us.qasm())
            }
        }
        
         return "\(qasms.joined(separator: " "))"
    }
}
