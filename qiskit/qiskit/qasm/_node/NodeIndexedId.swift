//
//  NodeIndexedId.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeIndexedId: Node {

    public let identifer: Node?
    public let parameter: Node?
    public let index: Int = 0

    public init(identifier: Node, parameter: Node) {
        self.identifer = identifier
        self.parameter = parameter
    }
    
    public override var type: NodeType {
        return .N_INDEXEDID
    }
    
    public override func qasm() -> String {
        guard let ident = identifer else {
            assertionFailure("Invalid NodeDecl Operation")
            return ""
        }
        var qasm: String = "\(ident.qasm())"
       
        if let param = parameter {
            qasm += "[\(param.qasm())]"
        }
        return qasm
    }
}
