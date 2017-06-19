//
//  NodeDecl.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeDecl: Node {
    
    var register: Node?
    var identifier: Node?
    var nninteger: Node?
    public init(register: Node?, identifier: Node?, nninteger: Node?) {
        super.init(type: .N_DECL)
        self.register = register
        self.identifier = identifier
        self.nninteger = nninteger
    }
    
    override public func qasm() -> String {
        guard let reg = register else {
            assertionFailure("Invalid NodeDecl Operation")
            return ""
        }
        guard let ident = identifier else {
            assertionFailure("Invalid NodeDecl Operation")
            return ""
        }
        guard let integer = nninteger else {
            assertionFailure("Invalid NodeDecl Operation")
            return ""
        }
        return "\(reg.qasm()) \(ident.qasm()) [\(integer.qasm())];"
    }

}
