//
//  Program.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM program.
children is a list of nodes (statements).
*/
@objc public final class NodeProgram: Node  {

    public private(set) var statements: [Node]?
    
    public init(statement: Node?) {
        super.init()
        if let stmt = statement {
            self.statements = [stmt]
        }
    }
    
    public func addStatement(statement: Node) {
        statements?.append(statement)
    }
    
    public override var type: NodeType {
        return .N_PROGRAM
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let stmnts = statements {
            for s in stmnts {
                _children.append(s)
            }
        }
        return _children
    }
    
    public override func qasm() -> String {
        
        var qasms: [String] = []
        if let stmt = statements {
            qasms += stmt.flatMap({ (node: Node) -> String in
                                    return node.qasm()
                                    })
        }
        return qasms.joined(separator: "\n")
    }
}
