//
//  External.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM external function.
 children[0] is an id node with the name of the function.
 children[1] is an expression node.
 */
@objc public final class NodeExternal: Node {

    public static let externalFunctions = ["sin", "cos", "tan", "exp", "ln", "sqrt"]

    public let operation: String
    public let expression: Node?
    
    public init(operation: String, expression: Node?) {
        self.operation = operation
        self.expression = expression
    }
    
    public override var type: NodeType {
        return .N_EXTERNAL
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let exp = expression {
            _children.append(exp)
        }
        return _children
    }

    public override func qasm() -> String {
        var qasm = operation
        if let exp = expression {
            qasm += "( \(exp.qasm()) )"
        }
        return qasm
    }

}
