//
//  NodeMixedList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeMixedList: Node {

    public private(set) var idlists: [Node]?
    public private(set) var indexedids: [Node]?
    
    public init(idlist: Node?, argument: Node?) {
        if let idlst = idlist {
            if idlists == nil {
                idlists = [idlst]
            } else {
                idlists!.append(idlst)
            }
        }
        if let arg = argument {
            if indexedids == nil {
                indexedids = [arg]
            } else {
                indexedids!.append(arg)
            }
        }
    }
    
    public func addIdList(idlist: Node) {
        idlists?.append(idlist)
    }
   
    public func addArgument(argument: Node) {
        indexedids?.append(argument)
    }
    public override var type: NodeType {
        return .N_MIXEDLIST
    }
    public override var children: [Node] {
        return []
    }
    public override func qasm() -> String {
        var qasms: [String] = []
        
        if let idls = idlists {
            for idl in idls {
                qasms.append(idl.qasm())
            }
        }
        
        if let iids = indexedids {
            for iid in iids {
                qasms.append(iid.qasm())
            }
        }
    
        return qasms.joined(separator: ",")
    }

}
