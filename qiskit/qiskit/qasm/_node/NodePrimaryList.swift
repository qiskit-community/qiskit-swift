//
//  PrimaryList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodePrimaryList: Node {

    public init(children: [Node]) {
        super.init(type: .N_PRIMARYLIST)
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
