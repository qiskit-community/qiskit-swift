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
    public let elistorarg: Node?
    public let argument: Node?
    
    public init(identifier: Node?, explistorarg: Node?, argument: Node?) {
        self.op = identifier            // u | cx
        self.elistorarg = explistorarg  // explist or argument
        self.argument = argument        // argument
        
        if self.op?.type == .N_CNOT {
            (self.op as? NodeCnot)?.updateNode(arg1: self.elistorarg, arg2: self.argument)
        }
    }
    
    public override var type: NodeType {
        return .N_UNIVERSALUNITARY
    }
    
    public override func qasm() -> String {
       
        guard let operation = op else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }

        guard let eora = elistorarg else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }

        switch operation.type {
        case .N_U:
            guard let a = argument else {
                assertionFailure("Invalid NodeUniversalUnitary Operation")
                return ""
            }
            return "\(operation.qasm()) ( \(eora.qasm()) ) \(a.qasm());"
        case .N_CNOT:
            return "\(operation.qasm())"
        default:
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
    }
}
