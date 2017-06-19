//
//  NodeAnyList.swift
//  qiskit
//
//  Created by Joe Ligman on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeAnyList: Node {
    
    public let list: Node

    public init(list: Node) {
        self.list = list
    }
    
    public override var type: NodeType {
        return .N_ANYLIST
    }
    
    public override var children: [Node] {
        return [self.list]
    }
    
    public override func qasm() -> String {
        return self.list.qasm()
    }
}
