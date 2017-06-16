//
//  NodeGoplist.swift
//  qiskit
//
//  Created by Joe Ligman on 6/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeGoplist: Node {
    
    var barrier: Node?
    var uop: Node?
    var idlist: Node?
    var goplist: [Node]?
    
    public init(barrier: Node?, uop: Node?, idlist: Node?, goplist: Node?) {
        super.init(type: .N_GOPLIST)
        
        self.barrier = barrier
        self.uop = uop
        self.idlist = idlist
        
        if let gplist = goplist as? NodeGoplist {
            if gplist.goplist == nil {
                gplist.goplist = []
            } else {
                 gplist.goplist!.append(self)
            }
        }

    }
    

    override public func qasm() -> String {
        
        if let up = uop {
            if goplist == nil {
                return "\(up.qasm())" // uop
            } else {
                var goplists: [String] = []
                if let list = goplist {
                    goplists = list.flatMap({ (node: Node) -> String in
                        return node.qasm()
                    })
                }
                return "\(goplists.joined(separator: ",")) \(up)" // goplist uop
            }
        }
        
        if let bar = barrier,
            let idlst = idlist {
            if goplist == nil {
                return "\(bar.qasm()) \(idlst.qasm())" // barrier idlist
            } else {
                var goplists: [String] = []
                if let list = goplist {
                    goplists = list.flatMap({ (node: Node) -> String in
                        return node.qasm()
                    })
                }
                return "\(goplists.joined(separator: ",")) \(bar.qasm()) \(idlst.qasm())" // goplist barrier idlist
            }
        }
    
        return ""
    }
}
