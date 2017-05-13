//
//  QComment.swift
//  qiskit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 QASM Comment class
 */
public final class QComment: QStatement {

    public let text: String

    public init(_ text: String = "") {
        self.text = text
    }

    public var description: String {
        return "// \(self.text)"
    }
}
