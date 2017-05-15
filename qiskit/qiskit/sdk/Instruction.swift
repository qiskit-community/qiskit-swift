//
//  Instruction.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Generic quantum computer instruction.
 */
public class Instruction {

    public let name: String
    private let param: [AnyObject]
    private let arg: [(Register,Int)]
    private let circuit: QuantumCircuit?
    private var control: (ClassicalRegister, Int)? = nil

    /**
     Create a new instruction.
     
     - parameter name: instruction name string
     - parameter param: list of real parameters
     - parameter arg: list of pairs (Register, index)
     - parameter circuit: QuantumCircuit or CompositeGate containing this instruction
     */
    public init(_ name: String, _ param: [AnyObject], _ arg: [(Register,Int)], _ circuit: QuantumCircuit? = nil) {
        self.name = name
        self.param = param
        self.arg = arg
        self.circuit = circuit
    }

    /**
     Raise exception if self.circuit is nil.
     */
    public func check_circuit() throws {
        if self.circuit == nil {
            throw QISKitException.intructionCircuitNil
        }
    }

    /**
     Add classical control on register classical and value val.
     */
    public func c_if(_ classical: Register, _ val: Int) throws {
        try self.check_circuit()
        try self.circuit!.check_creg(classical)
        if val < 0 {
            throw QISKitException.controlValueNegative
        }
        self.control = (classical as! ClassicalRegister, val)
    }

    /**
     Apply any modifiers of this instruction to another one.
     */
    public func _modifiers(gate: Gate) throws {
        if self.control != nil {
            try self.check_circuit()
            if !gate.circuit!.has_register(self.control!.0) {
                throw QISKitException.controlregnotfound(name: self.control!.0.name)
            }
            try gate.c_if(self.control!.0, self.control!.1)
        }
    }
}
