//
//  QU.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Built-in Single Qubit Gate class
 */
public final class QU: Uop {

    public let expList: [String]
    public let argument: QId

    public init(_ expList: [String], _ argument: QId) {
        self.expList = expList
        self.argument = argument

    }

    public var description: String {
        var text = "u("
        for i in 0..<self.expList.count {
            if i > 0 {
                text.append(",")
            }
            text.append("\(self.expList[i])")
        }
        text.append(")")
        if !self.argument.identifier.isEmpty {
            text.append(" \(self.argument.identifier)")
        }
        return text
    }
}
