//
//  Gate.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGate: Node {

    public let n_args: Int = 0
    public let n_bits: Int = 0
    public let arguments: Node? = nil
    public let bitlist: Node? = nil
    public let body: NodeGate? = nil

    public override var type: NodeType {
        return .N_GATE
    }
    public override var children: [Node] {
        var array: [Node] = []
        if let node = self.arguments {
            array.append(node)
        }
        if let node = self.bitlist {
            array.append(node)
        }
        if let node = self.body {
            array.append(node)
        }
        return array
    }
    public override func qasm() -> String {
        let qasm: String = "gate"
        return qasm
    }
    public func calls() -> [String] {
        return []
    }
}
