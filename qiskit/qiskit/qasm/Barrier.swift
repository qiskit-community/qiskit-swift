//
//  Barrier.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/12/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum Barrier class
 */
public final class Barrier: Statement {

    public let idList: [QId]

    public init(_ idList: [QId]) {
        self.idList = idList
    }

    public var description: String {
        var text = "barrier "
        for i in 0..<self.idList.count {
            if i > 0 {
                text.append(",")
            }
            text.append("\(self.idList[i].identifier)")
        }
        return text
    }
}
