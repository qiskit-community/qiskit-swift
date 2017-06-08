//
//  Barrier.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeBarrier: Node {

    public init() {
        super.init(type: .N_BARRIER)
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
