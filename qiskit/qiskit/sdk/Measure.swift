//
//  Measure.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Measurement class
 */
public final class Measure: Qop {

    public let argument1: QId
    public let argument2: QId

    public init(_ argument1: QId, _ argument2: QId) {
        self.argument1 = argument1
        self.argument2 = argument2

    }

    public var description: String {
        return "measure \(self.argument1.identifier) -> \(self.argument2.identifier)"
    }
}
