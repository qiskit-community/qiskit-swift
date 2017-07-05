//
//  NodeGopList.swift
//  qiskit
//
//  Created by Joe Ligman on 7/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

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
    
    public override func qasm() -> String {
        var qasms: [String] = []
        if let list = gateops {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: "\n")
    }
}

