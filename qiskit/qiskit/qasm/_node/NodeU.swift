//
//  NodeU.swift
//  qiskit
//
//  Created by Joe Ligman on 6/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeU: Node {
    
    public override var type: NodeType {
        return .N_U
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
        let qasm: String = "U"
        return qasm
    }
}
