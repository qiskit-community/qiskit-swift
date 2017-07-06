//
//  Real.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM real number.
This node has no children. The data is in the value field.
*/

@objc public final class NodeReal: Node {

    public let value: Double
    
    public init(id: Double) {
        self.value = id
    }
    
    public override var type: NodeType {
        return .N_REAL
    }

    public override func qasm() -> String {
        return self.value.format(15) // TODO: control the precision
    }
}
