//
//  Qreg.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeQreg: Node {

    public var nodeId: Node?
    public var nodeNNInt: Node?
    public var line: Int = 0
    public var file: String = ""
    public var index: Int = 0
    

    public override var type: NodeType {
        return .N_QREG
    }
    
    public override var name: String {
        return (nodeId as? NodeId)?.identifier ?? super.name
    }

    public func updateNode(identifier: Node?, nninteger: Node?) {
        nodeId = identifier
        nodeNNInt = nninteger
        index = (nodeId as? NodeId)?.index ?? 0
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        
        if let ident = nodeId {
            _children.append(ident)
        }
        
        if let nnint = nodeNNInt {
            _children.append(nnint)
        }
        
        return _children
    }
    
    public override func qasm() -> String {
        var qasm: String = "qreg"
        if let nid = nodeId {
            qasm += " \(nid.qasm())"
        }
        if let nnint = nodeNNInt {
            qasm += " [\(nnint.qasm())]"
        }
        qasm += ";"
        return qasm
    }
}
