//
//  Int.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeNNInt: Node {

    public let value: Int

    public init(value: Int) {
        self.value = value
    }
    public override var type: NodeType {
        return .N_INT
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
        let qasm: String = "\(value)"
        return qasm
    }
}
