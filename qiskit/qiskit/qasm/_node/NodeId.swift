//
//  Id.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeId: Node {

    public var identifier: String = ""
    
    public init(identifier: String) {
        super.init(type: .N_ID)
        self.identifier = identifier
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
