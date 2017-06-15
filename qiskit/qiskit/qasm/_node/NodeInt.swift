//
//  Int.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeNNInt: Node {

    public var nninteger: Int = Int.allZeros
    public init(value: Int) {
        super.init(type: .N_INT)
        nninteger = value
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
