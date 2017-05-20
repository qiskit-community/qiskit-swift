//
//  Header.swift
//  qiskit
//
//  Created by Manoel Marques on 5/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class Header: QuantumCircuitHeader {

    override public var value: String {
        return "\(super.value)\ninclude \"qelib1.inc\";"
    }
}

extension QuantumCircuit {
    convenience public init(_ regs: [Register]) throws {
        try self.init(regs, Header())
    }
}
