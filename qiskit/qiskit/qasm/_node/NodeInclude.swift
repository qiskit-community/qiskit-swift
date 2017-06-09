//
//  NodeInclude.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeInclude: Node {
    
    public init(file: String) {
        super.init(type: .N_INCLUDE)
        super.file = file
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
