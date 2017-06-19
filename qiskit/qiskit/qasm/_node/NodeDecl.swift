//
//  NodeDecl.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeDecl: Node {
    
    public let register: Node?
    public let identifier: Node?
    public let nninteger: Node?

    public init(register: Node?, identifier: Node?, nninteger: Node?) {
        self.register = register
        self.identifier = identifier
        self.nninteger = nninteger
    }
    public override var type: NodeType {
        return .N_DECL
    }
    public override var children: [Node] {
        var array: [Node] = []
        if let node = self.register {
            array.append(node)
        }
        if let node = self.identifier {
            array.append(node)
        }
        if let node = self.nninteger {
            array.append(node)
        }
        return array
    }
    public override func qasm() -> String {
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
