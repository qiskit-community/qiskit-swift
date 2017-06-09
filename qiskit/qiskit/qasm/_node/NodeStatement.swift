//
//  NodeStatement.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

@objc public class NodeStatment: Node {
    
    var p1: Node?
    var p2: Node?
    var p3: Node?
    var p4: Node?
    
    public init(p1: Node?, p2: Node?, p3: Node?, p4: Node?) {
        super.init(type: .N_STATEMENT)
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
        self.p4 = p4
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
