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
