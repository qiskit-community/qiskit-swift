//
//  Cnot.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeCnot: Node {

    public init(children: [Node]) {
        super.init(type: .N_CNOT)
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
