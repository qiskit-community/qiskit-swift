//
//  Measure.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
/*
 Node for an OPENQASM measure statement.
 children[0] is a primary node (id or indexedid)
 children[1] is a primary node (id or indexedid)
 */
@objc public final class NodeMeasure: Node {

    public var arg1: Node?
    public var arg2: Node?
    
    public init(arg1: Node?, arg2: Node?) {
        self.arg1 = arg1
        self.arg2 = arg2
    }
    
    public override var type: NodeType {
        return .N_MEASURE
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let a1 = arg1 {
            _children.append(a1)
        }
        if let a2 = arg2 {
            _children.append(a2)
        }
        return _children
    }
    
    public override func qasm() -> String {
        guard let a1 = arg1 else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        guard let a2 = arg2 else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        return "measure \(a1.qasm()) -> \(a2.qasm());"
    }
}
