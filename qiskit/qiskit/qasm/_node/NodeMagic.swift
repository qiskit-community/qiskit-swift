//
//  Magic.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeMagic:  Node {

    public override var type: NodeType {
        return .N_MAGIC
    }
    
    public override func qasm() -> String {
        let qasm: String = "OPENQASM "
        return qasm
    }

}
