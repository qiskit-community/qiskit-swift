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
    public var gateBody: Node?
    
    public init(gate: Node?, identifier: Node?, idlist1: Node?, idlist2: Node?) {
        self.gate = gate
        (self.gate as? NodeGate)?.updateNode(identifier: identifier, list1: idlist1, list2: idlist2)
    }
    
    public func updateNode(gateBody: Node) {
        self.gateBody = gateBody
    }
    
    public override var type: NodeType {
        return .N_GATEDECL
    }
    
    public override func qasm() -> String {
        guard let g8 = gate else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        var qasm = g8.qasm()
        if let gb = gateBody {
            qasm += "{ \(gb.qasm()) }"
        }
        return qasm
    }
}
