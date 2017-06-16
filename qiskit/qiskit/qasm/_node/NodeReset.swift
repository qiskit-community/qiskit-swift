//
//  Reset.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeReset: Node {
    
    public init() {
        super.init(type: .N_RESET)
    }
    
    override public func qasm() -> String {
        let qasm: String = "reset"
        return qasm
    }
}
