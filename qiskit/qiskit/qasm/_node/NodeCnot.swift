//
//  Cnot.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM CNOT statement.
 children[0], children[1] are id nodes if CX is inside a gate body,
 otherwise they are primary nodes.
 */
@objc public final class NodeCnot: Node {

    public var arg1: Node?
    public var arg2: Node?
    public init(arg1: Node?, arg2: Node?) {
        self.arg1 = arg1
        self.arg2 = arg2
    }
    
    public override var type: NodeType {
        return .N_CNOT
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
        var qasm: String = "CX"
        if let a1 = arg1 {
            qasm += " \(a1.qasm())"
        }
        
        if let a2 = arg2 {
            qasm += ", \(a2.qasm())"
        }
        qasm += ";"
        return qasm
    }

}
