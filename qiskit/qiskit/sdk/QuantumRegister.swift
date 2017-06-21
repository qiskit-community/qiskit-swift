//
//  QuantumRegister.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Qubits Register class
 */
public final class QuantumRegister: Register {

    public let name:String
    public let size:Int

    public init(_ name: String, _ size: Int) throws {
        self.name = name
        self.size = size
        try self.checkProperties()
    }

    public subscript(index: Int) -> QuantumRegisterTuple {
        get {
            if index < 0 || index >= self.size {
                fatalError("Index out of range")
            }
            return QuantumRegisterTuple(self, index)
        }
    }

    public var description: String {
        return "qreg \(self.name)[\(self.size)]"
    }
}

public final class QuantumRegisterTuple: RegisterArgument {
    public let register: QuantumRegister
    public let index: Int

    init(_ register: QuantumRegister, _ index: Int) {
        self.register = register
        self.index = index
    }

    public var identifier: String {
        return "\(self.register.name)[\(self.index)]"
    }
}
