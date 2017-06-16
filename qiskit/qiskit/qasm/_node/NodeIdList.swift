//
//  IdList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeIdList: Node {
    
    public var idList: [Node]?

    public init(idList: Node?, identifier: Node?) {
        super.init(type: .N_IDLIST)
        if let idlst = idList as? NodeIdList {
            if idlst.idList == nil {
                idlst.idList = []
            } else {
                idlst.idList!.append(self)
            }
        }
    }
    
    override public func qasm() -> String {
        preconditionFailure("qasm not implemented")
    }
}
