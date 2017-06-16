//
//  External.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeExternal: Node {

    static let externalFunctions = ["sin", "cos", "tan", "exp", "ln", "sqrt"]
    var operation: String?
    public init(operation: String) {
        super.init(type: .N_EXTERNAL)
        self.operation = operation
    }
    
    override public func qasm() -> String {
        guard let op = operation else {
            assertionFailure("Invalid Enternal Operation")
            return ""
        }
        return op
    }

}
