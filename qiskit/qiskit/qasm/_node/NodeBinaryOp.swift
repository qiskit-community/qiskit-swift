//
//  BinaryOp.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeBinaryOp: Node {

    public var op: String = ""
    
    public init(op: String, children: [Node]) {
        super.init(type: .N_BINARYOP)
        self.op = op
        self.children = children
    }
    
    override public func qasm() -> String {
        let lhs = children[0]
        let rhs = children[1]
        if lhs.type == .N_BINARYOP {
            return lhs.qasm()
        }
        if rhs.type == .N_BINARYOP {
            return rhs.qasm()
        }
        return "\(lhs.qasm()) \(op) \(rhs.qasm())"
    }

}
