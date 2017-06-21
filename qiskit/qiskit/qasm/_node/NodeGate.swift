//
//  Gate.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGate: Node {

    public override var type: NodeType {
        return .N_GATE
    }
    
    public override func qasm() -> String {
        let qasm: String = "gate"
        return qasm
    }
    
    public func calls() -> [String] {
        return []
    }
}
