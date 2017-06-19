//
//  NodeStatement.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public class NodeStatment: Node {
    
    public var p1: Node?
    public var p2: Node?
    public var p3: Node?
    public var p4: Node?
    
    public init(p1: Node?, p2: Node?, p3: Node?, p4: Node?) {
        super.init(type: .N_STATEMENT)

        self.p1 = p1 // decl | gatedecl | opqaue | qop | ifn | barrier
        self.p2 = p2 // nil | goplist | id | anylist
        self.p3 = p3 // nil | idlist
        self.p4 = p4 // nil | idlist | nninteger | qop
    }
    
    override public func qasm() -> String {
 
        guard let s1 = p1 else {
            assertionFailure("Invalid NodeStatment Operation")
            return ""
        }
        
        switch s1.type {
            case .N_DECL:
                return "\(s1.qasm())"
            case .N_GATEDECL:
                if let s2 = p2 {
                    return "\(s1.qasm()) \(s2.qasm()) }"
                }
                return "\(s1.qasm()) }"
            case .N_OPAQUE:
                    guard let s2 = p2 else {
                        assertionFailure("Invalid NodeStatment Operation")
                        return ""
                    }

                    guard let s3 = p3 else {
                        assertionFailure("Invalid NodeStatment Operation")
                        return ""
                    }

                    if let s4 = p4 {
                      return "\(s1.qasm()) \(s2.qasm()) ( \(s3.qasm()) ) \(s4.qasm()) ;"
                    }
                    return "\(s1.qasm()) \(s2.qasm()) \(s3.qasm());"
            case .N_QOP:
                return "\(s1.qasm())"
            case .N_IF:
                guard let s2 = p2 else {
                    assertionFailure("Invalid NodeStatment Operation")
                    return ""
                }
                
                guard let s3 = p3 else {
                    assertionFailure("Invalid NodeStatment Operation")
                    return ""
                }
                
                guard let s4 = p4 else {
                    assertionFailure("Invalid NodeStatment Operation")
                    return ""
                }
            
                return "\(s1.qasm()) ( \(s2.qasm()) == \(s3.qasm()) ) \(s4.qasm()) ;"
            case .N_BARRIER:
                guard let s2 = p2 else {
                    assertionFailure("Invalid NodeStatment Operation")
                    return ""
                }
                return "\(s1.qasm()) \(s2.qasm());"
            default:
                assertionFailure("Invalid NodeStatment Operation")
                return ""
        }
    }
}
