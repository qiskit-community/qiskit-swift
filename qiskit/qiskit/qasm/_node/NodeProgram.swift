//
//  Program.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeProgram: Node  {

    var program: Node?
    var statement: Node?
    
    public init(program: Node?, statement: Node?) {
        super.init(type: .N_PROGRAM)
        self.program = program
        self.statement = statement
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
