//
//  NodeU.swift
//  qiskit
//
//  Created by Joe Ligman on 6/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeU: Node {
    
    public init() {
        super.init(type: .N_U)
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
