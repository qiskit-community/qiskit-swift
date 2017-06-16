//
//  Real.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeReal: Node {

    public var real: Float = Float.leastNonzeroMagnitude
    
    public init(id: Float) {
        super.init(type: .N_REAL)
        real = id
    }
    
    override public func qasm() -> String {
        let qasm: String = "\(real)"
        return qasm
    }
}
