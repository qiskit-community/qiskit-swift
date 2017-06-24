//
//  Reset.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeReset: Node {
    
    public var arg: Node?

    public override var type: NodeType {
        return .N_RESET
    }
    
    public func updateNode(arg: Node?) {
        self.arg = arg
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let a = arg {
            _children.append(a)
        }
        return _children
    }

    public override func qasm() -> String {
        guard let a = arg else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        return "reset \(a.qasm());"
    }

}
