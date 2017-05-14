//
//  Opaque.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 QASM Opaque Gate class
 */
public final class Opaque: QId, Statement {

    public let idList1: [QId]
    public let idList2: [QId]

    public init(_ identifier: String, _ idList1: [QId], _ idList2: [QId]) {
        self.idList1 = idList1
        self.idList2 = idList2
        super.init(identifier)
    }

    public var description: String {
        var text = "opaque \(self.identifier)"
        if !self.idList1.isEmpty {
            text.append("(")
            for i in 0..<self.idList1.count {
                if i > 0 {
                    text.append(",")
                }
                text.append("\(self.idList1[i].identifier)")
            }
            text.append(")")
        }
        text.append(" ")
        for i in 0..<self.idList2.count {
            if i > 0 {
                text.append(",")
            }
            text.append("\(self.idList2[i].identifier)")
        }
        return text
    }
}
