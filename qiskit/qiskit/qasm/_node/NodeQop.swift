//
//  NodeQop.swift
//  qiskit
//
//  Created by Joe Ligman on 6/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeQop: Node {
    
    public var op: Node?
    public var arg: Node?
    public var arg2: Node?
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        super.init(type: .N_QOP)

        self.op = object1   // uop | measure | reset
        self.arg = object2  // argument | nil
        self.arg2 = object3 // argument| nil
    }
    
    override public func qasm() -> String {
        
        guard let operation = op else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }
        
        if operation.type == .N_UNIVERSALUNITARY {
            return "\(operation.qasm())"
        }

        guard let arg1 = arg else {
            assertionFailure("Invalid NodeQop Operation")
            return ""
        }

        if operation.type == .N_MEASURE {
       
            guard let arg2 = arg2 else {
                assertionFailure("Invalid NodeQop Operation")
                return ""
            }
            
            return "\(operation.qasm()) \(arg1.qasm()) -> \(arg2.qasm());"
            
        }
        
        return "\(operation.qasm()) \(arg1.qasm());"
    }
}
