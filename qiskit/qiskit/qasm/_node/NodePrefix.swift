//
//  Prefix.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodePrefix: Node {

    public let op: String
    public let external: NodeExternal?
    private let _children: [Node]

    public init(op: String, children: [Node]) {
        self.op = op
        if NodeExternal.externalFunctions.contains(op) {
            external = NodeExternal(operation: op)
        }
        else {
            external = nil
        }
        self._children = children
    }
    
    public override var type: NodeType {
        return .N_PREFIX
    }
    
    public override var children: [Node] {
        return self._children
    }
    
    public override func qasm() -> String {
        let operand = self.children[0]
        return "\(op) (\(operand.qasm()))"
    }
}
