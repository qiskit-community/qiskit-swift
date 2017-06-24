//
//  Opaque.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeOpaque: Node {

    public var identifier: Node?
    public var idlist1: Node?
    public var idlist2: Node?
    
    public override var type: NodeType {
        return .N_OPAQUE
    }
    
    public func updateNode(identifier: Node?, list1: Node?, list2: Node?) {
        self.identifier = identifier
        self.idlist1 = list1
        self.idlist2 = list2
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let ident = identifier {
            _children.append(ident)
        }
        if let l1 = idlist1 {
            _children.append(l1)
        }
        if let l2 = idlist2 {
            _children.append(l2)
        }
        return _children
    }
    

    public override func qasm() -> String {
        var qasm: String = "opaque"
        
        guard let ident = identifier else {
            assertionFailure("Invalid NodeOpaque Operation")
            return ""
        }

        guard let l1 = idlist1 else {
            assertionFailure("Invalid NodeOpaque Operation")
            return ""
        }
        
        if let l2 = idlist2 {
            qasm += " \(ident.qasm()) ( \(l1.qasm()) ) \(l2.qasm());"
        } else {
            qasm += " \(ident.qasm()) \(l1.qasm());"
        }
        
        return qasm
    }
}
