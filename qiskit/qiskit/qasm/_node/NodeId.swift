//
//  Id.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM id.
 The node has no children but has fields name, line, and file.
 There is a flag is_bit that is set when XXXXX to help with scoping.
 */
@objc public final class NodeId: Node {

    public var _name: String = ""
    public var line: Int = 0
    public var file: String = ""
    public var index: Int = 0  // FIXME where does the index come from?
    public var is_bit: Bool = false
    
    public init(identifier: String, line: Int) {
        self._name = identifier
        self.line = line
        self.file = "" // FIXME find the name
        self.is_bit = false
    }
    
    public override var type: NodeType {
        return .N_ID
    }
    
    public override var name: String {
        return _name
    }

    public override func qasm() -> String {
        let qasm: String = _name
        return qasm
    }
}
