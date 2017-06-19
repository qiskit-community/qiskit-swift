//
//  UniversalUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeUniversalUnitary: Node {

    public let op: Node?
    public let arg: Node?
    public let arg2: Node?
    
    public init(object1: Node?, object2: Node?, object3: Node?) {
        self.op = object1   // u | cx | id
        self.arg = object2  // exp, argument, anylist, explist
        self.arg2 = object3 // argument | anylist | nil
    }
    public override var type: NodeType {
        return .N_UNIVERSALUNITARY
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
       
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
            return "\(operation.qasm()) \(a.qasm());"
        default:
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
    }
}
