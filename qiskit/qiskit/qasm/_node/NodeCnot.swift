//
//  Cnot.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeCnot: Node {

    public var arg1: Node?
    public var arg2: Node?
    
    public override var type: NodeType {
        return .N_CNOT
    }
    
    
    public func updateNode(arg1: Node?, arg2: Node?) {
        self.arg1 = arg1
        self.arg2 = arg2
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
