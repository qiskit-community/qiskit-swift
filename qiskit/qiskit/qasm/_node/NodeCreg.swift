//
//  Creg.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeCreg: Node {
    
    var id: Node?
    public init(children: [Node]) {
        super.init(type: .N_CREG)
        self.id = children[0]
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
