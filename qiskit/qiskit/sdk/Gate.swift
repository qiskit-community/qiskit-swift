//
//  Gate.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 User Defined Gate class
 */
public class Gate: Instruction {

    public init(_ name: String, _ params: [Double], _ qargs: [QuantumRegister]) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs)
    }
    
    public init(_ name: String, _ params: [Double], _ qargs: [QuantumRegisterTuple]) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs)
    }

    /**
     Invert this gate.
     */
    public func inverse() throws -> Gate {
         throw QISKitException.inversenotimpl
    }

    /**
     Add controls to this gate.
     */
    public func q_if(_ qregs:[QuantumRegister]) throws -> Gate {
        throw QISKitException.controlnotimpl
    }
}
