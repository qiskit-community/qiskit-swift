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
    public let arg: Node?
    public let arg2: Node?
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        self.op = object1   // uop | measure | reset
        self.arg = object2  // argument | nil
        self.arg2 = object3 // argument| nil
    }
    
    public override var type: NodeType {
        return .N_QOP
    }
    
    public override func qasm() -> String {
        
        guard let operation = op else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }

        if operation.type == .N_MEASURE {
       
            guard let arg1 = arg else {
                assertionFailure("Invalid NodeQop Operation")
                return ""
            }
            
            guard let arg2 = arg2 else {
                assertionFailure("Invalid NodeQop Operation")
                return ""
            }
            
            return "\(operation.qasm()) \(arg1.qasm()) -> \(arg2.qasm());"
            
        }
       
        if operation.type == .N_RESET {
            
            guard let arg1 = arg else {
                assertionFailure("Invalid NodeQop Operation")
                return ""
            }
            
            return "\(operation.qasm()) \(arg1.qasm());"
        }

        return "\(operation.qasm())"
    }
}
