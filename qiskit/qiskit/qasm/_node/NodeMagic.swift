//
//  Magic.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeMagic: Node {

    public init() {
        super.init(type: .N_MAGIC)
    }
    
    override public func qasm() -> String {
        let qasm: String = "OPENQASM "
        return qasm
    }

}
