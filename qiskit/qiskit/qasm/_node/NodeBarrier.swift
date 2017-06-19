//
//  Barrier.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeBarrier: Node {

    public override var type: NodeType {
        return .N_BARRIER
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
        let qasm: String = "barrier"
        return qasm
    }
}
