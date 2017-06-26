//
//  BinaryOp.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM binary operation exprssion.
 children[0] is the operation, as a character.
 children[1] is the left expression.
 children[2] is the right expression.
 */

@objc public final class NodeBinaryOp: Node {

    public let op: String
    public let _children: [Node]
    
    public init(op: String, children: [Node]) {
        self.op = op
        self._children = children
    }
    
    public override var type: NodeType {
        return .N_BINARYOP
    }
    
    public override func qasm() -> String {
        let lhs = _children[0]
        let rhs = _children[1]
        if lhs.type == .N_BINARYOP {
            return lhs.qasm()
        }
        if rhs.type == .N_BINARYOP {
            return rhs.qasm()
        }
        return "\(lhs.qasm()) \(op) \(rhs.qasm())"
    }

}
