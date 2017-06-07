//
//  UniversalUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeUniversalUnitary: Node {

    public init(object1: Node?, object2: Node?, object3: Node?) {
        super.init(type: .N_UNIVERSALUNITARY)
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
