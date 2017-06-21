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
    public let line: Int
    public let file: String
    public var is_bit: Bool = false
    
    public init(identifier: String, line: Int) {
        self.identifier = identifier
        self.line = line
        self.file = "" // FIXME find the name
        self.is_bit = false
    }
    
    public override var type: NodeType {
        return .N_ID
    }
    
    public override func qasm() -> String {
        let qasm: String = identifier
        return qasm
    }
}
