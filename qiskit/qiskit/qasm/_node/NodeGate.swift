//
//  Gate.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeGate: Node {

    public var identifier: Node?
    public var arguments: Node?
    public var bitlist: Node?

    public override var type: NodeType {
        return .N_GATE
    }

    public func updateNode(identifier: Node?, list1: Node?, list2: Node?) {
        self.identifier = identifier
        
        
        if list2 != nil {
            arguments = list1
            bitlist = list2
        } else {
            arguments = nil
            bitlist = list1
        }
        
        // # To help with scoping rules, so we know the id is a bit,
        // # this flag is set to True when the id appears in a gate declaration
        (self.identifier as? NodeId)?.is_bit = true
        
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        if let ident = identifier {
            _children.append(ident)
        }
        if let args = arguments {
            _children.append(args)
        }
        if let btlist = bitlist {
            _children.append(btlist)
        }
        return _children
    }

    
    public override func qasm() -> String {
        var qasm: String = "gate"
        
        if let ident = identifier {
            qasm += " \(ident.qasm())"
        }
        if let args = arguments {
            qasm += " \(args.qasm())"
        }
        if let btlist = bitlist {
            qasm += " \(btlist.qasm())"
        }
        
        return qasm
    }
    
 
}
