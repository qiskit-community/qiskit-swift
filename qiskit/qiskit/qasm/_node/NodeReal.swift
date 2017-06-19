//
//  Real.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeReal: Node {

    public let value: Float
    
    public init(id: Float) {
        self.value = id
    }
    public override var type: NodeType {
        return .N_REAL
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
        let qasm: String = "\(value)"
        return qasm
    }
}
