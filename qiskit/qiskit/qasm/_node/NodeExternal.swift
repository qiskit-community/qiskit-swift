//
//  External.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeExternal: Node {

    public static let externalFunctions = ["sin", "cos", "tan", "exp", "ln", "sqrt"]

    public let operation: String

    public init(operation: String) {
        self.operation = operation
    }
    
    public override var type: NodeType {
        return .N_EXTERNAL
    }
    
    public override var children: [Node] {
        return []
    }
    
    public override func qasm() -> String {
        return operation
    }

}
