//
//  Reset.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeReset: Node {
    
    public override var type: NodeType {
        return .N_RESET
    }
    
    public override func qasm() -> String {
        let qasm: String = "reset"
        return qasm
    }
}
