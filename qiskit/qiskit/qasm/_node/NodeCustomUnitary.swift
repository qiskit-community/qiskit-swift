//
//  NodeCustomUnitary.swift
//  qiskit
//
//  Created by Joe Ligman on 6/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/*
 Node for an OPENQASM custom gate statement.

children[0] is an id node.
children[1] is an exp_list (if len==3) or primary_list.
children[2], if present, is a primary_list.

Has properties:
.id = id node
.name = gate name string
.arguments = None or exp_list node
.bitlist = primary_list node
*/
@objc public final class NodeCustomUnitary: Node {
    
    public let identifier: Node?
    public let arguments: Node?
    public let bitlist: Node?
    public var _name: String = ""

    public init(identifier: Node?, arguments: Node?, bitlist: Node?) {
        self.identifier = identifier     // id
        self.arguments = arguments   // anylist
        self.bitlist = bitlist   // explist
    
         if let _id = self.identifier as? NodeId{
            _name = _id._name
        }
    }
    
    public override var type: NodeType {
        return .N_CUSTOMUNITARY
    }

    public override var name: String {
        return _name
    }

    public override func qasm() -> String {
        var qasm = "\(self.name)"
        if let args = self.arguments {
            qasm += " (" + args.qasm() + ")"
        }
        if let bits = self.bitlist {
            qasm += " \(bits.qasm());"
        }
        return qasm
    }
}
