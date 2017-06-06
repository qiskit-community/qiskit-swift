//
//  Int.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeNNInt: Node {

    public var value: Int = 0
    
    public init(value: Int) {
        super.init(type: .N_INT)
        self.value = value
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
