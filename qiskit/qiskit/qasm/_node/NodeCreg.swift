//
//  Creg.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM creg statement.
children[0] is an indexedid node.
*/
@objc public final class NodeCreg: Node {

    public let indexedid: Node?
    public var _name: String = ""
    public var line: Int = 0
    public var file: String = ""
    public var index: Int = 0
    
    public init(indexedid: Node?, line: Int, file: String) {
        
        self.indexedid = indexedid
        if let _id = self.indexedid as? NodeId{
            // Name of the qreg
            self._name = _id.name
            // Source line number
            self.line = _id.line
            // Source file name
            self.file = _id.file
            // Size of the register
            self.index = _id.index
        }
    }

    public override var type: NodeType {
        return .N_CREG
    }
    
    public override var name: String {
        return _name
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
            assertionFailure("Invalid NodeQreg Operation")
            return ""
        }
        return "creg " + iid.qasm() + ";"
    }
    

}
