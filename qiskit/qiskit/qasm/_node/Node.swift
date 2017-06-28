//
//  Node.swift
//  qiskit
//
//  Created by Manoel Marques on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public enum NodeType: String {
    case N_BARRIER = "barrier"
    case N_BINARYOP = "binop"
    case N_CNOT = "cnot"
    case N_CREG = "creg"
    case N_CUSTOMUNITARY = "custom_unitary"
    case N_EXPRESSIONLIST = "expression_list"
    case N_EXTERNAL = "external"
    case N_GATE = "gate"
    case N_GATEBODY = "gate_body"
    case N_GATEOPLIST = "gateoplist"
    case N_ID = "id"
    case N_IDLIST = "id_list"
    case N_IF = "if"
    case N_INCLUDE = "incld"
    case N_INDEXEDID = "indexed_id"
    case N_INT = "int"
    case N_MAGIC = "magic"
    case N_MAINPROGRAM = "main_program"
    case N_MEASURE = "measure"
    case N_OPAQUE = "opaque"
    case N_PREFIX = "prefix"
    case N_PRIMARYLIST = "primary_list"
    case N_PROGRAM = "program"
    case N_REAL = "real"
    case N_RESET = "reset"
    case N_QREG = "qreg"
    case N_UNIVERSALUNITARY = "universal_unitary"
    case N_UNDEFINED = "undefined"
}

@objc public class Node : NSObject {

    var name: String {
        return self.type.rawValue
    }
    
    var type: NodeType {
        return .N_UNDEFINED
    }
    
    var children: [Node] {
        preconditionFailure("Node children not implemented")
    }
    
    func qasm() -> String {
        preconditionFailure("Node qasm not implemented")
    }
}
