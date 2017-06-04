//
//  GateData.swift
//  qiskit
//
//  Created by Manoel Marques on 5/31/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 "opaque" = True or False
 "n_args" = number of real parameters
 "n_bits" = number of qubits
 "args"   = list of parameter names
 "bits"   = list of qubit names
 "body"   = GateBody AST node
 */

final class GateData: NSCopying {

    let opaque: Bool
    let n_args: Int
    let n_bits: Int
    let args: [String]
    let bits: [RegBit]
    let body: Node

    init(_ opaque: Bool, _ n_args: Int, _ n_bits: Int, _ args: [String], _ bits: [RegBit], _ body: Node) {
        self.opaque = opaque
        self.n_args = n_args
        self.n_bits = n_bits
        self.args = args
        self.bits = bits
        self.body = body
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let body = self.body.copy(with: zone) as! Node
        return GateData(self.opaque, self.n_args, self.n_bits, self.args, self.bits, body)
    }
}
