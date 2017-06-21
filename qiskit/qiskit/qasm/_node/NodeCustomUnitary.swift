//
//  NodeCustomUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeCustomUnitary: Node {
    
        public let op: Node?
        public let anylist: Node?
        public let explist: Node?
    
        public init(identifier: Node?, anylist: Node?, explist: Node?) {
            self.op = identifier     // id
            self.anylist = anylist   // anylist
            self.explist = explist   // explist
        }
        
        public override var type: NodeType {
            return .N_CUSTOMUNITARY
        }
        
        public override func qasm() -> String {
            
            guard let operation = op else {
                assertionFailure("Invalid NodeCustomUnitary Operation")
                return ""
            }
            
            guard let a = anylist else {
                assertionFailure("Invalid NodeCustomUnitary Operation")
                return ""
            }
            
            switch operation.type {
                case .N_ID:
                if let e = explist {
                    return "\(operation.qasm()) ( \(a.qasm()) ) \(e.qasm());"
                }
                return "\(operation.qasm()) \(a.qasm());"
            default:
                assertionFailure("Invalid NodeCustomUnitary Operation")
                return ""
            }
        }
}
