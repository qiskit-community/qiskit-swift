//
//  CX.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 controlled-NOT gate.
 */
public final class CnotGate: Uop {

    public let argument1: QId
    public let argument2: QId

    public init(_ argument1: QId, _ argument2: QId) {
        self.argument1 = argument1
        self.argument2 = argument2

    }

    public var description: String {
        return "cx \(self.argument1.identifier),\(self.argument2.identifier)"
    }
}
