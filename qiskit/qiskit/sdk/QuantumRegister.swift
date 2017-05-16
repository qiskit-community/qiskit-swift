//
//  QuantumRegister.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Qubits Register class
 */
public final class QuantumRegister: Register {

    public subscript(index: Int) -> QuantumRegisterTuple {
        get {
            if index < 0 || index >= self.size {
                fatalError("Index out of range")
            }
            return QuantumRegisterTuple(self, index)
        }
    }

    public override init(_ name: String, _ size: Int) throws {
        try super.init(name, size)
    }

    public override var description: String {
        return "qreg \(self.name)[\(self.size)]"
    }
}

public final class QuantumRegisterTuple: RegisterTuple {
    init(_ register: QuantumRegister, _ index: Int) {
        super.init(register,index)
    }
}
