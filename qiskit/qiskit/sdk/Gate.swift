//
//  Gate.swift
//  qiskit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 User Defined Gate class
 */
public class Gate: Instruction {

    public init(_ name: String, _ params: [Double], _ qargs: [QuantumRegister], _ circuit: QuantumCircuit?) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs, circuit)
    }
    
    public init(_ name: String, _ params: [Double], _ qargs: [QuantumRegisterTuple], _ circuit: QuantumCircuit?) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        super.init(name, params, qargs, circuit)
    }

    /**
     Invert this gate.
     */
    public override func inverse() -> Gate {
        preconditionFailure("inverse not implemented")
    }

    /**
     Add controls to this gate.
     */
    public override func q_if(_ qregs:[QuantumRegister]) -> Gate {
        preconditionFailure("q_if not implemented")
    }
}
