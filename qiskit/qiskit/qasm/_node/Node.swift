//
//  Node.swift
//  qiskit
//
//  Created by Manoel Marques on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

//TODO Mock AST node - replace by real ast node
class Node : NSCopying {

    // I am not sure about types but those properties are being accessed in Unroller
    let type: String = ""
    let name: String = ""
    let index: Int = 0
    let line: Int = 0
    let file: String = ""
    let arguments: [AnyObject] = []
    let bitlist: [AnyObject] = []
    let n_args: Int = 0
    let n_bits: Int = 0
    let body: String = ""
    let children: [Node] = []
    let value: String = ""
    
    public init() {
        if type(of: self) == Node.self {
            fatalError("Abstract class instantiation.")
        }
    }
    func qasm() -> String {
        preconditionFailure("Node qasm not implemented")
    }
    func calls() -> [String] {
        preconditionFailure("Node calls not implemented")
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        preconditionFailure("Node copy not implemented")
    }
}
