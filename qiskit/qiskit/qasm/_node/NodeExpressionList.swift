//
//  ExpressionList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeExpressionList: Node {

    public var expressionList: [Node]?
    
    public init(expression: Node, expressionList: Node?) {
        super.init(type: .N_EXPRESSIONLIST)
        
        if let exlist = expressionList as? NodeExpressionList {
            if exlist.expressionList == nil {
                exlist.expressionList = []
            } else {
                exlist.expressionList!.append(self)
            }
        }
    }
    
    override public func qasm() -> String {
        var qasms: [String] = []
        if let list = expressionList {
            qasms = list.flatMap({ (node: Node) -> String in
                return node.qasm()
            })
        }
        return qasms.joined(separator: ",")
    }
}
