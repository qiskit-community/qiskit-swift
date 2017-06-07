//
//  IdList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeIdList: Node {
    
    var identifier: Node?
    public init(idList: Node?, identifier: Node?) {
        super.init(type: .N_IDLIST)
        self.identifier = identifier
    }
    
    override public func qasm() -> String {
        return "TODO"
    }
}
