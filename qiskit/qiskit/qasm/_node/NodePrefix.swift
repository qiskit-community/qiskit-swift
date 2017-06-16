//
//  Prefix.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodePrefix: Node {

    public var op: String = ""
    public var external: NodeExternal?

    public init(op: String, children: [Node]) {
        super.init(type: .N_PREFIX)
        self.op = op
        if NodeExternal.externalFunctions.contains(op) {
            external = NodeExternal(operation: op)
        }
        self.children = children
    }
    
    override public func qasm() -> String {
        let operand = self.children[0]
        return "\(op) (\(operand.qasm()))"
    }
}
