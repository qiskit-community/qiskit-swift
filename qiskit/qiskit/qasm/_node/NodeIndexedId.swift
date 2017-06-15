//
//  NodeIndexedId.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeIndexedId: Node {
    public var identifer: Node?
    public init(identifier: Node, parameter: Node) {
        super.init(type: .N_INDEXEDID)
        self.identifer = identifier
        self.children = [parameter]
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
