//
//  QIf.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum Condition class
 */
public final class QIf: Statement {

    public let identifier: QId
    public let nnInteger: UInt
    public let qop: Qop

    public init(_ identifier: QId, _ nnInteger: UInt, _ qop: Qop) {
        self.identifier = identifier
        self.nnInteger = nnInteger
        self.qop = qop
    }

    public var description: String {
        return "if(\(self.identifier.identifier)==\(self.nnInteger)) \(self.qop)"
    }
}
