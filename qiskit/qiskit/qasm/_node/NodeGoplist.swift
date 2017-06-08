//
//  NodeGoplist.swift
//  qiskit
//
//  Created by Joe Ligman on 6/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeGoplist: Node {
    
    var barrier: Node?
    var uop: Node?
    var idlist: Node?
    var goplist: Node?
    public init(barrier: Node?, uop: Node?, idlist: Node?, goplist: Node?) {
        super.init(type: .N_GOPLIST)
        self.barrier = barrier
        self.uop = uop
        self.goplist = goplist
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
