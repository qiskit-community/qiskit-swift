//
//  NodeMixedList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeMixedList: Node {

    var item1: Node?
    var item2: Node?
    var item3: Node?
    public init(item1: Node?, item2: Node?, item3: Node?) {
        super.init(type: .N_MIXEDLIST)
        self.item1 = item1
        self.item2 = item2
        self.item3 = item3
    }
    
    override public func qasm() -> String {
        return "TODO"
    }

}
