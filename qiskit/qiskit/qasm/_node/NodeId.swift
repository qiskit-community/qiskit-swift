//
//  Id.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeId: Node {

    public var name: String?
    
    public init(name: String) {
        super.init(type: .N_ID)
        self.name = name
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
