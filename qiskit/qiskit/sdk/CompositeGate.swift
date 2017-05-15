//
//  CompositeGate.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Composite gate, a sequence of unitary gates.
 */
public final class CompositeGate: Statement {

    public let identifier: String
    public let idList1: [QId]
    public let idList2: [QId]
    public var body: [Statement] = []

    public init(_ identifier: String, _ idList1: [QId], _ idList2: [QId]) {
        self.identifier = identifier
        self.idList1 = idList1
        self.idList2 = idList2
    }

    public var description: String {
        var text = "gate \(self.identifier)"
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
        text.append("\n{")
        for statement in self.body {
            text.append("\n  \(statement.description)")
            if statement is Comment || statement is CompositeGate {
                continue
            }
            text.append(";")
        }
        text.append("\n}")
        return text
    }

    public func append(_ statement: Statement) -> CompositeGate {
        self.body.append(statement)
        return self
    }

    public func append(contentsOf: [Statement]) -> CompositeGate {
        self.body.append(contentsOf: contentsOf)
        return self
    }

    public static func + (left: CompositeGate, right: Statement) -> CompositeGate {
        let gateDecl = CompositeGate(left.identifier, left.idList1, left.idList2)
        return gateDecl.append(contentsOf: left.body).append(right)
    }

    public static func += (left: inout CompositeGate, right: Statement) {
        left.body.append(right)
    }
}
