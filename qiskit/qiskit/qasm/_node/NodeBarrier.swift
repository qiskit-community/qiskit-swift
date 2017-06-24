//
//  Barrier.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeBarrier: Node {

    public var list: Node?
    
    public override var type: NodeType {
        return .N_BARRIER
    }
    
    public func updateNode(anylist: Node?) {
        self.list = anylist
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
