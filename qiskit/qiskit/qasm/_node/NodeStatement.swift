//
//  NodeStatement.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

@objc public class NodeStatment: Node {
    
    public var p1: Node?
    public var p2: Node?
    public var p3: Node?
    public var p4: Node?
    
    public init(p1: Node?, p2: Node?, p3: Node?, p4: Node?) {
        super.init(type: .N_STATEMENT)

        self.p1 = p1 // decl | gatedecl | opqaue | qop | ifn | barrier
        self.p2 = p2 // nil | goplist | id | anylist
        self.p3 = p3 // nil | idlist
        self.p4 = p4 // nil | idlist | nninteger | qop
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
