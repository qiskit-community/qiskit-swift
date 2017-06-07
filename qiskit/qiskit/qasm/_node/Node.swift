//
//  Node.swift
//  qiskit
//
//  Created by Manoel Marques on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public enum NodeType: String {
    case N_ANYLIST = "any_list"
    case N_ARGUMENT = "argument"
    case N_BARRIER = "barrier"
    case N_BINARYOP = "binop"
    case N_CNOT = "cnot"
    case N_CREG = "creg"
    case N_CUSTOMUNITARY = "custom_unitary"
    case N_EXPRESSIONLIST = "expression_list"
    case N_EXTERNAL = "external"
    case N_GATE = "gate"
    case N_GATEBODY = "gate_body"
    case N_ID = "id"
    case N_IDLIST = "id_list"
    case N_IF = "if"
    case N_INDEXEDID = "indexed_id"
    case N_INT = "int"
    case N_MAGIC = "magic"
    case N_MEASURE = "measure"
    case N_MIXEDLIST = "mixed_list"
    case N_OPAQUE = "opaque"
    case N_PREFIX = "prefix"
    case N_PRIMARYLIST = "primary_list"
    case N_PROGRAM = "program"
    case N_QREG = "qreg"
    case N_REAL = "real"
    case N_RESET = "reset"
    case N_UNIVERSALUNITARY = "universal_unitary"
    case N_UNDEFINED = "undefined"
  
}

@objc public class Node : NSObject {

    var root: Node?
    var type: NodeType = .N_UNDEFINED
    
    var children: [Node] = []

    public init(type: NodeType, children: [Node] = [], root: Node? = nil) {
        super.init()
        self.root = root
        self.type = type
        self.children = children
    }
    
    public func qasm() -> String {
        preconditionFailure("Node qasm not implemented")
    }
    func calls() -> [String] {
        preconditionFailure("Node calls not implemented")
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        preconditionFailure("Node copy not implemented")
    }
}
