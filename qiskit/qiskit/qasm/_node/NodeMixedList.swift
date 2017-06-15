//
//  NodeMixedList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeMixedList: Node {

    public var mixedList: [Node]?

    public init(listNode: Node?, item2: Node?, item3: Node?) {
        super.init(type: .N_MIXEDLIST)

        if let lst = listNode as? NodeMixedList {
            if lst.mixedList == nil {
                lst.mixedList = []
            } else {
                lst.mixedList!.append(self)
            }
        }
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }

}
