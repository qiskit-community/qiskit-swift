//
//  ClassicalRegister.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Bits Register class
 */
public final class ClassicalRegister: Register, Decl {

    public subscript(index: Int) -> Qbit {
        get {
            if index < 0 || index >= size {
                fatalError("Index out of range")
            }
            return Qbit(self.identifier, index)
        }
    }

    public override init(_ identifier: String, _ size: Int) throws {
        try super.init(identifier, size)
    }

    public var description: String {
        return "creg \(self.identifier)[\(self.size)]"
    }
}
