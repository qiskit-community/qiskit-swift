//
//  GateDecl.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGateDecl: Node {

    public let gate: Node?
    public let identifier: Node?
    public let idlist1: Node?
    public let idlist2: Node?

    public init(gate: Node?, identifier: Node?, idlist1: Node?, idlist2: Node?) {
        self.gate = gate
        self.identifier = identifier
        self.idlist1 = idlist1
        self.idlist2 = idlist2
    }
    public override var type: NodeType {
        return .N_GATEDECL
    }
    public override var children: [Node] {
        var array: [Node] = []
        if let node = self.gate {
            array.append(node)
        }
        if let node = self.identifier {
            array.append(node)
        }
        if let node = self.idlist1 {
            array.append(node)
        }
        if let node = self.idlist2 {
            array.append(node)
        }
        return array
    }
    public override func qasm() -> String {
        guard let g8 = gate else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        guard let ident = identifier else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        guard let list1 = idlist1 else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        if let list2 = idlist2 {
            return "\(g8.qasm()) \(ident.qasm()) (\(list1.qasm())) \(list2.qasm()) {"
        }
        
        return "\(g8.qasm()) \(list1.qasm()) {" // FIXME: figure out the correct parenthesis 
    }
}
