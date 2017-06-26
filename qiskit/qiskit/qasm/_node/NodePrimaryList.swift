//
//  NodePrimaryList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
Node for an OPENQASM primarylist.
children is a list of primary nodes. Primary nodes are indexedid or id.
*/

@objc public final class NodePrimaryList: Node {
    
    public private(set) var identifiers: [Node]?
   
    public init(identifier: Node?) {
        super.init()
        if let ident = identifier {
            if identifiers == nil {
                self.identifiers = [ident]
            } else {
                identifiers!.append(self)
            }
        }
    }
    
    public func addIdentifier(identifier: Node) {
        identifiers?.append(identifier)
    }
    
    public override var type: NodeType {
        return .N_PRIMARYLIST
    }
    
    public override var children: [Node] {
        return (identifiers != nil) ? identifiers! : []
    }
    
    public override func qasm() -> String {
        var qasms: [String] = []
        if let list = identifiers {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: ",")
    }
}
