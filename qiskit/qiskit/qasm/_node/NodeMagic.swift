//
//  Magic.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeMagic:  Node {

    public var nodeVersion: NodeReal?
    
    public override var type: NodeType {
        return .N_MAGIC
    }
    
    public func updateNode(version: Node?) {
        nodeVersion = (version as? NodeReal)
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        
        if let version = nodeVersion {
            _children.append(version)
        }
        
        return _children
    }
    
    public override func qasm() -> String {
        var qasm: String = "OPENQASM"
        if let version = nodeVersion {
            qasm += " \(version.qasm())"
        }
        qasm += ";"
        return qasm
    }

}
