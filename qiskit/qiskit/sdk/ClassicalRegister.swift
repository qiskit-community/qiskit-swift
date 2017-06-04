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

    public subscript(index: Int) -> ClassicalRegisterTuple {
        get {
            if index < 0 || index >= self.size {
                fatalError("Index out of range")
            }
            return ClassicalRegisterTuple(self, index)
        }
    }
    
    public override var description: String {
        return "creg \(self.name)[\(self.size)]"
    }
}

public final class ClassicalRegisterTuple: RegisterTuple {
    public override var register: ClassicalRegister {
        return super.register as! ClassicalRegister
    }
    init(_ register: ClassicalRegister, _ index: Int) {
        super.init(register,index)
    }
}
