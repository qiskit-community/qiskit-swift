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
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        self.op = object1   // uop | measure | reset
        if self.op?.type == .N_MEASURE {
            (self.op as? NodeMeasure)?.updateNode(arg1: object2, arg2: object3)
        } else if self.op?.type == .N_RESET {
            (self.op as? NodeReset)?.updateNode(arg: object2)
        }
    }
    
    public override var type: NodeType {
        return .N_QOP
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let operation = op {
            _children.append(operation)
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
