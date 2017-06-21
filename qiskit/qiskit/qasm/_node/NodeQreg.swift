//
//  Qreg.swift
//  qiskit
//
//  Created by Joe Ligman on 6/4/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeQreg: Node {

    public let index: Int = 0

    public override var type: NodeType {
        return .N_QREG
    }
    
    public override func qasm() -> String {
        let qasm: String = "qreg"
        return qasm
    }
}
