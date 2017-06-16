//
//  NodeQop.swift
//  qiskit
//
//  Created by Joe Ligman on 6/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeQop: Node {
    
    public var op: Node?
    public var arg: Node?
    public var arg2: Node?
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        super.init(type: .N_QOP)

        self.op = object1   // measure | reset
        self.arg = object2  // argument
        self.arg2 = object3 // argument| nil
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
