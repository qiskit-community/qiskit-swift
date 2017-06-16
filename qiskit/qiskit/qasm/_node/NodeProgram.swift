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
    public var statements: [Node]?
    
    public init(program: Node?, statement: Node?) {
        super.init(type: .N_PROGRAM)
        
        if let stmt = statement {
            if self.statements == nil {
                self.statements = [stmt]
            } else {
                self.statements?.append(stmt)
            }
        }
        
        if let prgm = program as? NodeProgram {
            if prgm.program == nil {
                prgm.program = []
            }
            prgm.program!.append(self)
        }
    }
    
    public func addStatement(statement: Node) {
        statements?.append(statement)
    }
    
    override public func qasm() -> String {
        
        var qasms: [String] = []
        if let prg = program {
            qasms = prg.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        
        if let stmt = statements {
            qasms += stmt.flatMap({ (node: Node) -> String in
                        return node.qasm()
                    })
        }
        return qasms.joined(separator: "\n")
        
    }
}
