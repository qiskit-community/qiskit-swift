//
//  Gate.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 User Defined Gate class
 */
public final class Gate: Uop {

    public let identifier: String
    public let expList: [String]
    public let anyList: [QId]

    public init(_ identifier: String, _ expList: [String], _ anyList: [QId]) {
        self.identifier = identifier
        self.expList = expList
        self.anyList = anyList
    }

    public var description: String {
        var text = "\(self.identifier)"
        if !self.expList.isEmpty {
            text.append("(")
            for i in 0..<self.expList.count {
                if i > 0 {
                    text.append(",")
                }
                text.append("\(self.expList[i])")
            }
            text.append(")")
        }
        text.append(" ")
        for i in 0..<self.anyList.count {
            if i > 0 {
                text.append(",")
            }
            text.append("\(self.anyList[i].identifier)")
        }
        return text
    }
}
