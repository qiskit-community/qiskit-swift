//
//  Program.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeProgram: Node  {

    public var program: [Node]?
    public var statement: Node?
    
    public init(program: Node?, statement: Node?) {
        super.init(type: .N_PROGRAM)
        self.statement = statement
    
        if let prgm = program as? NodeProgram {
            if prgm.program == nil {
                prgm.program = []
            }
            prgm.program!.append(self)
        }
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
