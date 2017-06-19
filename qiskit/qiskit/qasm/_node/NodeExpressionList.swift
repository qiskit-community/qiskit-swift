//
//  ExpressionList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeExpressionList: Node {

    public let expressionList: [Node]? = nil
    
    public init(expression: Node, expressionList: Node?) {
    /*    if let exlist = expressionList as? NodeExpressionList {
            if exlist.expressionList == nil {
                exlist.expressionList = []
            } else {
                exlist.expressionList!.append(self)
            }
        }*/
    }
    public override var type: NodeType {
        return .N_EXPRESSIONLIST
    }
    public override var children: [Node] {
        if let list = self.expressionList {
            return list
        }
        return []
    }
    public override func qasm() -> String {
        var qasms: [String] = []
        if let list = expressionList {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: ",")
    }
}
