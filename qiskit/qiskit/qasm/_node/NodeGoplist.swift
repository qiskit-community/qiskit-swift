//
//  NodeGoplist.swift
//  qiskit
//
//  Created by Joe Ligman on 6/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeGoplist: Node {
    
    var barrieridlist: [(barrier:Node, idlist:Node)]?
    var uops: [Node]?

    public init(barrier: Node, idlist: Node) {
        super.init(type: .N_GOPLIST)
        
        if barrieridlist == nil {
            barrieridlist = [(barrier, idlist)]
        } else {
            barrieridlist!.append((barrier, idlist))
        }
    }

    public init(uop: Node) {
        super.init(type: .N_GOPLIST)
        if uops == nil {
            uops = [uop]
        } else {
            uops!.append(uop)
        }
    }

    public func addBarrierIdlist(barrier: Node, idlist: Node) {
        barrieridlist?.append((barrier, idlist))
    }
    
    public func addUop(uop: Node) {
        uops?.append(uop)
    }
    
    override public func qasm() -> String {
        
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
