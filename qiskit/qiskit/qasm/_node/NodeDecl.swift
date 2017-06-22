//
//  NodeDecl.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeDecl: Node {
    
    public let op: Node?
    
    public init(op: Node?, identifier: Node?, nninteger: Node?) {
        self.op = op
        
        if self.op?.type == .N_CREG {
            (self.op as? NodeCreg)?.updateNode(identifier: identifier, nninteger: nninteger)
        } else if op?.type == .N_QREG {
            (self.op as? NodeQreg)?.updateNode(identifier: identifier, nninteger: nninteger)
        } else {
            assertionFailure("Invalid NodeDecl")
        }
    }
    
    public override var type: NodeType {
        return .N_DECL
    }
        
    public override func qasm() -> String {
        guard let o = self.op else {
            assertionFailure("Invalid NodeDecl Operation")
            return ""
        }
        return "\(o.qasm())"
    }

}
