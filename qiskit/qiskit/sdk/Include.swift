//
//  Include.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 QASM Include class
 */
public final class Include: Statement {

    public let filePath: String

    public init(_ filePath: String) {
        self.filePath = filePath
    }

    public var description: String {
        return "include \"\(self.filePath)\""
    }
}
