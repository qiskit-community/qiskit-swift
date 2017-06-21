//
//  GateDecl.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGateDecl: Node {

    public let gate: Node?
    public let identifier: Node?
    public let idlist1: Node?
    public let idlist2: Node?
    public var gateBody: NodeStatment?
    public var bit_list: [(name: String, position: Int)] = []
    
    public init(gate: Node?, identifier: Node?, idlist1: Node?, idlist2: Node?) {
        self.gate = gate
        self.identifier = identifier
        self.idlist1 = idlist1
        self.idlist2 = idlist2
    
        // # To help with scoping rules, so we know the id is a bit,
        // # this flag is set to True when the id appears in a gate declaration
        (self.identifier as? NodeId)?.is_bit = true
        
        // create the bit list - the bit list is an array of tuples representing the id names and their positions
        if let l1 = self.idlist1 as? NodeIdList {
            if let ids = l1.identifiers {
                for index in 0..<ids.count {
                    if let i = ids[index] as? NodeId{
                        bit_list.append((i.name, index))
                    }
                }
            }
        }
        
        if let l2 = self.idlist2 as? NodeIdList {
            if let ids = l2.identifiers {
                for index in 0..<ids.count {
                    if let i = ids[index] as? NodeId{
                        bit_list.append((i.name, index))
                    }
                }
            }
        }
        
    }
    
    public override var type: NodeType {
        return .N_GATEDECL
    }
    
    public override func qasm() -> String {
        guard let g8 = gate else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        guard let ident = identifier else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        guard let list1 = idlist1 else {
            assertionFailure("Invalid NodeGateDecl Operation")
            return ""
        }
        if let list2 = idlist2 {
            return "\(g8.qasm()) \(ident.qasm()) (\(list1.qasm())) \(list2.qasm()) {"
        }
        
        return "\(g8.qasm()) \(list1.qasm()) {" // FIXME: figure out the correct parenthesis 
    }
}
