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

    init(_ name: String, _ params: [Double], _ qargs: [QuantumRegister]) {
        super.init(name, params, qargs)
    }
    
    init(_ name: String, _ params: [Double], _ qargs: [QuantumRegisterTuple]) {
        super.init(name, params, qargs)
    }

    /**
     Invert this gate.
     */
    public func inverse() throws {
         throw QISKitException.inversenotimpl
    }

    /**
     Add controls to this gate.
     */
    public func q_if(qregs:[QuantumRegister]) throws {
        throw QISKitException.controlnotimpl
    }
}
