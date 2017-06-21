//
//  ClassicalRegister.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Bits Register class
 */
public final class ClassicalRegister: Register {

    public let name:String
    public let size:Int

    public init(_ name: String, _ size: Int) throws {
        self.name = name
        self.size = size
        try self.checkProperties()
    }

    public subscript(index: Int) -> ClassicalRegisterTuple {
        get {
            if index < 0 || index >= self.size {
                fatalError("Index out of range")
            }
            return ClassicalRegisterTuple(self, index)
        }
    }
    
    public var description: String {
        return "creg \(self.name)[\(self.size)]"
    }
}

public final class ClassicalRegisterTuple: RegisterArgument {
    public let register: ClassicalRegister
    public let index: Int

    init(_ register: ClassicalRegister, _ index: Int) {
        self.register = register
        self.index = index
    }

    public var identifier: String {
        return "\(self.register.name)[\(self.index)]"
    }
}
