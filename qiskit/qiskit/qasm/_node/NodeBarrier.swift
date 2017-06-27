//
//  Barrier.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
/*
 class Barrier(Node):
 Node for an OPENQASM barrier statement.
 children[0] is a primarylist node.
 */
@objc public final class NodeBarrier: Node {

    public var list: Node?
    
    public init(list: Node?) {
        self.list = list
    }

    public override var type: NodeType {
        return .N_BARRIER
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let al = list {
            _children.append(al)
        }
        return _children
    }

    
    public override func qasm() -> String {
        var qasm: String = "barrier"
        guard let l = list else {
            assertionFailure("Invalid NodeBarrier Operation")
            return ""
        }
        qasm += " \(l.qasm());"
        return qasm
    }
}
