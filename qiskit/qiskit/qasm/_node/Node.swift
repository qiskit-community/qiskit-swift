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
    case N_BARRIER = "barrier"
    case N_BINARYOP = "binop"
    case N_BITLIST = "bitlist"
    case N_BODY = "body"
    case N_CNOT = "cnot"
    case N_CREG = "creg"
    case N_DECL = "decl"
    case N_U = "u"
    case N_CUSTOMUNITARY = "custom_unitary"
    case N_EXPRESSIONLIST = "expression_list"
    case N_EXTERNAL = "external"
    case N_GOPLIST = "goplist"
    case N_GATE = "gate"
    case N_GATEDECL = "gate_decl"
    case N_ID = "id"
    case N_IDLIST = "id_list"
    case N_IF = "if"
    case N_INCLUDE = "incld"
    case N_INDEXEDID = "indexed_id"
    case N_INT = "int"
    case N_MAINPROGRAM = "main_program"
    case N_MAGIC = "magic"
    case N_MEASURE = "measure"
    case N_MIXEDLIST = "mixed_list"
    case N_OPAQUE = "opaque"
    case N_QOP = "qop"
    case N_PREFIX = "prefix"
    case N_PRIMARYLIST = "primary_list"
    case N_PROGRAM = "program"
    case N_QREG = "qreg"
    case N_REAL = "real"
    case N_RESET = "reset"
    case N_STATEMENT = "statment"
    case N_UNIVERSALUNITARY = "universal_unitary"
    case N_UNDEFINED = "undefined"
}


@objc public class Node : NSObject {

    var root: Node?
    var arguments: Node?
    var bitlist: Node?
    var body: Node?
    
    // I am not sure about types but those properties are being accessed in Unroller
    var type: NodeType = .N_UNDEFINED
    var children: [Node] = []
  
    var name: String = ""
    var index: Int = 0
    var line: Int = 0
    var file: String = ""
    var n_args: Int = 0
    var n_bits: Int = 0
    var value: String = ""

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
