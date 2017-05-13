//
//  QReset.swift
//  qiskit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Reset qubit|qreg
 */
public final class QReset: Qqop {

    public let argument: QId

    public init(_ argument: QId) {
        self.argument = argument
    }

    public var description: String {
        return "reset \(self.argument.identifier)"
    }
}
