//
//  Id.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeId: Node {

    public let identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public override var type: NodeType {
        return .N_ID
    }
    
    public override var children: [Node] {
        return []
    }
    
    public override func qasm() -> String {
        let qasm: String = identifier
        return qasm
    }
}
