//
//  Gate.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeGate: Node {

    var id: Node?
    var arguments: Node?
    var bitlist: Node?
    var body: Node?
    
    public init(children: [Node]) {
        super.init(type: .N_GATE)
        self.id = children[0]
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
