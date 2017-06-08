//
//  NodeDecl.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

@objc public class NodeDecl: Node {
    
    var register: Node?
    var identifier: Node?
    var nninteger: Node?
    public init(register: Node?, identifier: Node?, nninteger: Node?) {
        super.init(type: .N_DECL)
        self.register = register
        self.identifier = identifier
        self.nninteger = nninteger
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
