//
//  Prefix.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM prefix expression.
children[0] is a prefix string such as '-'.
children[1] is an expression node.
*/
@objc public final class NodePrefix: Node {

    public let op: String
    public let _children: [Node]

    public init(op: String, children: [Node]) {
        self.op = op
        self._children = children
    }
    
    public override var type: NodeType {
        return .N_PREFIX
    }
    
    public override var children: [Node] {
        return _children
    }
    
    public override func qasm() -> String {
        let operand = self._children[0]
        if operand.type == .N_BINARYOP {
            return "\(op) (\(operand.qasm()))"
        }
        return "\(op)\(operand.qasm())"
    }
}
