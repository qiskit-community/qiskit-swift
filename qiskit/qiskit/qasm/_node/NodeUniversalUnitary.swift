//
//  UniversalUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
/*
Node for an OPENQASM U statement.
children[0] is an expressionlist node.
children[1] is a primary node (id or indexedid).
*/
@objc public final class NodeUniversalUnitary: Node {

    public let explist: Node?
    public let indexedid: Node?
    
    public init(explist: Node?, indexedid: Node?) {
        self.explist = explist
        self.indexedid = indexedid
    }
    
    public override var type: NodeType {
        return .N_UNIVERSALUNITARY
    }

    public override var children: [Node] {
        var _children: [Node] = []
        if let el = explist {
            _children.append(el)
        }
        if let iid = indexedid {
            _children.append(iid)
        }
        return _children
    }

    public override func qasm() -> String {
        guard let el = explist else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
        
        guard let iid = indexedid else {
            assertionFailure("Invalid NodeUniversalUnitary Operation")
            return ""
        }
        return "U (\(el.qasm())) \(iid.qasm());"
    }
}
