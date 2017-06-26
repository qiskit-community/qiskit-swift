//
//  NodeIndexedId.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM indexed id.
children[0] is an id node.
children[1] is an integer (not a node).
*/
@objc public final class NodeIndexedId: Node {

    public let identifer: Node?
    public var _name: String = ""
    public var line: Int = 0
    public var file: String = ""
    public var index: Int = 0
    
    public init(identifier: Node, index: Int) {
        self.identifer = identifier
        self.index = index
        if let _id = self.identifer as? NodeId{
            // Name of the qreg
            self._name = _id.name
            // Source line number
            self.line = _id.line
            // Source file name
            self.file = _id.file
        }
   }

    public override var type: NodeType {
        return .N_INDEXEDID
    }

    public override var name: String {
        return _name
    }
    
    public override func qasm() -> String {
        guard let ident = identifer else {
            assertionFailure("Invalid NodeIndexedId Operation")
            return ""
        }
        var qasm: String = "\(ident.qasm())"
        qasm += " [\(index)]"
        return qasm
    }
    
}
