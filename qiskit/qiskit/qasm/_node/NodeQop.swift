//
//  NodeQop.swift
//  qiskit
//
//  Created by Joe Ligman on 6/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeQop: Node {
    
    public let op: Node?
    public let arg1: Node?
    public let arg2: Node?
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        self.op = object1   // uop | measure | reset
        self.arg1 = object2  // argument | nil
        self.arg2 = object3 // argument| nil
        if self.op?.type == .N_MEASURE {
            (self.op as? NodeMeasure)?.updateNode(arg1: self.arg1, arg2: self.arg2)
        } else if self.op?.type == .N_RESET {
            (self.op as? NodeReset)?.updateNode(arg: self.arg1)
        }
    }
    
    public override var type: NodeType {
        return .N_QOP
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
        
        guard let operation = op else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        return "\(operation.qasm())"
    }
}
