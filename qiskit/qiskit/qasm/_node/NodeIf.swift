//
//  If.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeIf: Node {
  
    public var nodeId: Node?
    public var nodeNNInt: Node?
    public var nodeQop: Node?
    
    public override var type: NodeType {
        return .N_IF
    }
    
    public func updateNode(identifier: Node?, nninteger: Node?, qop: Node?) {
        nodeId = identifier
        nodeNNInt = nninteger
        nodeQop = qop
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let ident = nodeId {
            _children.append(ident)
        }
        if let nnint = nodeNNInt {
            _children.append(nnint)
        }
        if let qop = nodeQop {
            _children.append(qop)
        }
        
        return _children
    }
    
    public override func qasm() -> String {
        var qasm: String = "if"
        if let ident = nodeId {
            qasm += " (\(ident.qasm())"
        }
        if let nnint = nodeNNInt {
            qasm += " == \(nnint.qasm())"
        }
        if let qop = nodeQop {
            qasm += " ) \(qop.qasm())"
        }
        return qasm
    }
}
