//
//  BinaryOp.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeBinaryOp: Node {

    public let op: String
    private let _children: [Node]
    
    public init(op: String, children: [Node]) {
        self.op = op
        self._children = children
    }
    
    public override var type: NodeType {
        return .N_BINARYOP
    }
    
    public override var children: [Node] {
        return self._children
    }
    
    public override func qasm() -> String {
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
