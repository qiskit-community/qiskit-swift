//
//  CustomUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeCustomUnitary: Node {
    
    var id: Node?
    var arguments: Node?
    var bitlist: Node?
  
    public init(children: [Node]) {
        super.init(type: .N_CUSTOMUNITARY)
        self.id = children[0]
     }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
