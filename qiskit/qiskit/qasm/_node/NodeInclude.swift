//
//  NodeInclude.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

@objc public class NodeInclude: Node {
    
    var file: String?
    
    public init(file: String) {
        super.init(type: .N_INCLUDE)
        self.file = file
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
