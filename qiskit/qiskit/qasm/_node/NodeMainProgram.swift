//
//  NodeMainProgram.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

import Foundation

@objc public class NodeMainProgram: Node {
    
    var magic: Node?
    var version: Node?
    var incld: Node?
    var program: Node?
    
    public init(magic: Node?, version: Node?, incld: Node?, program: Node?) {
        super.init(type: .N_MAINPROGRAM)
        self.magic = magic
        self.version = version
        self.incld = incld
        self.program = program
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
