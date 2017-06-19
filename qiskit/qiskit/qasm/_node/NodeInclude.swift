//
//  NodeInclude.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeInclude: Node {

    public let file: String

    public init(file: String) {
        self.file = file
    }
    public override var type: NodeType {
        return .N_INCLUDE
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
        let qasm: String = "include \(file)"
        return qasm
    }
}
