//
//  NodeMixedList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeMixedList: Node {

    var idlists: [Node]?
    var indexedids: [Node]?
    
    public init(idlist: Node?, argument: Node?) {
        super.init(type: .N_MIXEDLIST)
        
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

    override public func qasm() -> String {
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
