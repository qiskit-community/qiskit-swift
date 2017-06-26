//
//  NodeMainProgram.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeMainProgram: Node {
    
    public let magic: Node?
    public let incld: Node?
    public let program: Node?
    
    public init(magic: Node?, version: Node?, incld: Node?, program: Node?) {
        self.magic = magic
        self.incld = incld
        self.program = program
    }
    
    public override var type: NodeType {
        return .N_MAINPROGRAM
    }
    
    public override func qasm() -> String {
        var qasm: String = magic?.qasm() ?? ""
        qasm += "\(incld?.qasm() ?? "");\n"
        qasm += "\(program?.qasm() ?? "")\n"
        return qasm
    }
}
