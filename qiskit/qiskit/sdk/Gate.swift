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
public final class Gate: Instruction, Uop {

    public let expList: [String]
    public let anyList: [QId]

    /**
     Create a new Unitary Gate.

     - parameter name: instruction name string
     - parameter param: list of real parameters
     - parameter arg: list of pairs (Register, index)
     - parameter circuit: QuantumCircuit or CompositeGate containing this gate
     */
    public init(_ name: String, _ param: [AnyObject], _ arg: [(Register,Int)], _ circuit: QuantumCircuit? = nil, _ expList: [String], _ anyList: [QId]) throws {
        for (register,_) in arg {
            if !(register is QuantumRegister) {
                throw QISKitException.notqreg
            }
        }
        self.expList = expList
        self.anyList = anyList
        super.init(name, param, arg, circuit)
    }

    public var description: String {
        var text = "\(self.name)"
        if !self.expList.isEmpty {
            text.append("(")
            for i in 0..<self.expList.count {
                if i > 0 {
                    text.append(",")
                }
                text.append("\(self.expList[i])")
            }
            text.append(")")
        }
        text.append(" ")
        for i in 0..<self.anyList.count {
            if i > 0 {
                text.append(",")
            }
            text.append("\(self.anyList[i].identifier)")
        }
        return text
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
