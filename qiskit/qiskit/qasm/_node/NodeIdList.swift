//
//  IdList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeIdList: Node {
    
    public var identifiers: [Node]?
    
    public init(identifier: Node?) {
        super.init(type: .N_IDLIST)
        
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
    
    override public func qasm() -> String {
        var qasms: [String] = []
        if let list = identifiers {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: ",")
    }
}

