//
//  UniversalUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeUniversalUnitary: Node {

    public var op: Node?
    public var arg: Node?
    public var arg2: Node?
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        super.init(type: .N_UNIVERSALUNITARY)
    
        self.op = object1   // u | cx | id
        self.arg = object2  // exp, argument, anylist, explist
        self.arg2 = object3 // argument | anylist | nil
    }
    
    override public func qasm() -> String {
       
        guard let operation = op else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }

        guard let a = arg else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }

        switch operation.type {
        case .N_U:
            guard let a2 = arg2 else {
                assertionFailure("Invalid NodeUniversalUnitary Operation")
                return ""
            }
            return "\(operation.qasm()) ( \(a.qasm()) ) \(a2.qasm());"
        case .N_CNOT:
            guard let a2 = arg2 else {
                assertionFailure("Invalid NodeUniversalUnitary Operation")
                return ""
            }
            return "\(operation.qasm()) \(a.qasm()), \(a2.qasm());"
        case .N_ID:
            if let a2 = arg2 {
                return "\(operation.qasm()) ( \(a.qasm()) ) \(a2.qasm());"
            }
            return "\(operation.qasm()) () \(a.qasm());"
        default:
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
    }
}
