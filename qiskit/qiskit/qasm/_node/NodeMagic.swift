//
//  Magic.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM file identifier/version statement ("magic number").
children[0] is a floating point number (not a node).
*/

@objc public final class NodeMagic:  Node {

    public let nodeVersion: NodeReal?

    public init(version: Node?) {
        self.nodeVersion = (version as? NodeReal)
    }

    public override var type: NodeType {
        return .N_MAGIC
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        
        if let version = nodeVersion {
            _children.append(version)
        }
        
        return _children
    }
    
    public override func qasm() -> String {
        guard let version = nodeVersion else {
            assertionFailure("Invalid NodeMagic Operation")
            return ""
        }
        return "OPENQASM \(version.value.format(1));"
    }

}
