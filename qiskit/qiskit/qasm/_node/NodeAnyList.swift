//
//  NodeAnyList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeAnyList: Node {
    
    var list: Node?
    public init(list: Node) {
        super.init(type: .N_ANYLIST)
        self.list = list
    }
    
    override public func qasm() -> String {
        guard let l = list else {
            assertionFailure("Invalid NodeAnyList Operation")
            return ""
        }
        return l.qasm()
    }
}
