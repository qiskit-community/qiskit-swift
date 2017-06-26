//
//  Reset.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM reset statement.
children[0] is a primary node (id or indexedid)
*/

@objc public final class NodeReset: Node {
    
    public let indexedid: Node?
 
    public init(indexedid: Node?) {
        self.indexedid = indexedid
    }
    
    public override var type: NodeType {
        return .N_RESET
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let a = indexedid {
            _children.append(a)
        }
        return _children
    }

    public override func qasm() -> String {
        guard let iid = indexedid else {
            assertionFailure("Invalid NodeReset Operation")
            return ""
        }
        return "reset \(iid.qasm());"
    }

}
