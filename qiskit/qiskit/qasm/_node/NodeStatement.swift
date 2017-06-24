//
//  NodeStatement.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeStatment: Node {
    
    public let op: Node?
    public let p2: Node?
    public let p3: Node?
    public let p4: Node?
    
    public init(p1: Node?, p2: Node?, p3: Node?, p4: Node?) {
        self.op = p1 // decl | gatedecl | opqaue | qop | ifn | barrier
        self.p2 = p2 // nil | goplist | id | anylist
        self.p3 = p3 // nil | idlist
        self.p4 = p4 // nil | idlist | nninteger | qop
    
        if let type = self.op?.type {
            switch type {
            case .N_GATEDECL:
                (self.op as? NodeGateDecl)?.updateNode(gateBody: self.p2)
            case .N_OPAQUE:
                (self.op as? NodeOpaque)?.updateNode(identifier: self.p2,
                                                     list1: self.p3,
                                                     list2: self.p4)
            case .N_IF:
                 (self.op as? NodeIf)?.updateNode(identifier: self.p2,
                                                  nninteger: self.p3,
                                                  qop: self.p4)
            case .N_BARRIER:
                (self.op as? NodeBarrier)?.updateNode(anylist: self.p2)
            default:
                break;
            }
        }
        super.init()
    }
    
    public override var type: NodeType {
        return .N_STATEMENT
    }
    
    
    public override var children: [Node] {
        var _children: [Node] = []
        
        if let operation = op {
            _children.append(operation)
        }
        return _children
    }
    

    public func calls() -> [String] {
        
        var idNameList: [String] = []
        
        if let op = self.op {
            if op.type == .N_GATEDECL {
                if let goplist = p2 as? NodeGoplist {
                    
                    if let bl = goplist.barriers {
                        for child in bl {
                            if let list = (child as! NodeBarrier).list as? NodeIdList {
                                if let ids = list.identifiers {
                                    for i in ids {
                                        if i.type == .N_CUSTOMUNITARY {
                                            idNameList.append(i.name)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if let uops = goplist.uops  {
                        for uop in uops {
                            if uop.type == .N_CUSTOMUNITARY {
                                idNameList.append(uop.name)
                            }
                        }
                    }
                }
            }
        }
        
        return idNameList
    }
    
    public override func qasm() -> String {
 
        guard let op = self.op else {
            assertionFailure("Invalid NodeStatment Operation")
            return ""
        }
        
        switch op.type {
            case .N_DECL:
                return "\(op.qasm())"
            case .N_GATEDECL:
                return "\(op.qasm())"
            case .N_OPAQUE:
                return "\(op.qasm())"
            case .N_QOP:
                return "\(op.qasm())"
            case .N_IF:
                return "\(op.qasm())"
            case .N_BARRIER:
                return "\(op.qasm())"
            default:
                assertionFailure("Invalid NodeStatment Operation")
                return ""
        }
    }
}
