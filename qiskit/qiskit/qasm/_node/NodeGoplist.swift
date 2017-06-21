//
//  NodeGoplist.swift
//  qiskit
//
//  Created by Joe Ligman on 6/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGoplist: Node {
    
    public private(set) var barrieridlist: [(barrier:Node, idlist:Node)]?
    public private(set) var uops: [Node]?

    public init(barrier: Node, idlist: Node) {
        barrieridlist = [(barrier, idlist)]
    }

    public init(uop: Node) {
        uops = [uop]
    }

    public func addBarrierIdlist(barrier: Node, idlist: Node) {
        barrieridlist?.append((barrier, idlist))
    }
    
    public func addUop(uop: Node) {
        uops?.append(uop)
    }
    
    public override var type: NodeType {
        return .N_GOPLIST
    }
    
    public override func qasm() -> String {
        
        var qasms: [String] = []
        if let bl = barrieridlist {
            for child in bl {
                qasms.append(child.barrier.qasm())
                qasms.append(child.idlist.qasm())
            }
        }
        if let ups = uops {
            for us in ups {
                qasms.append(us.qasm())
            }
        }
        
         return "\(qasms.joined(separator: ","))"
    }
}
