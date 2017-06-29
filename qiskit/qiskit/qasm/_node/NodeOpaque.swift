//
//  Opaque.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
/*
 Node for an OPENQASM opaque gate declaration.
 children[0] is an id node.
 If len(children) is 3, children[1] is an expressionlist node,
 and children[2] is an idlist node.
 Otherwise, children[1] is an idlist node.
 */
@objc public final class NodeOpaque: Node {

    public var identifier: Node?
    public var arguments: Node?
    public var bitlist: Node?
    
    public var _name: String = ""
    public var line: Int = 0
    public var file: String = ""
    public var index: Int = 0
    
    public var n_args: Int {
        get{
            return arguments?.children.count ?? 0
        }
    }
    
    public var n_bits: Int {
        get {
            return bitlist?.children.count ?? 0
        }
    }

    
    public init(identifier: Node?, arguments: Node?, bitlist: Node?) {
        self.identifier = identifier
        self.arguments = arguments
        self.bitlist = bitlist
        if let _id = self.identifier as? NodeId{
            // Name of the qreg
            self._name = _id.name
            // Source line number
            self.line = _id.line
            // Source file name
            self.file = _id.file
            // Size of the register
            self.index = _id.index
        }
    }
    
    public override var type: NodeType {
        return .N_OPAQUE
    }
   
    public override var name: String {
        return _name
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let ident = identifier {
            _children.append(ident)
        }
        if let l1 = arguments {
            _children.append(l1)
        }
        if let l2 = bitlist {
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

        guard let l1 = arguments else {
            assertionFailure("Invalid NodeOpaque Operation")
            return ""
        }
        
        if let l2 = bitlist {
            qasm += " \(ident.qasm()) ( \(l1.qasm()) ) \(l2.qasm());"
        } else {
            qasm += " \(ident.qasm()) \(l1.qasm());"
        }
        
        return qasm
    }
}
