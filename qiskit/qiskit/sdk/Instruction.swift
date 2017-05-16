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
public class Instruction: CustomStringConvertible {

    let name: String
    let params: [Double]
    let args: [RegisterArgument]
    var circuit: QuantumCircuit? = nil
    private var control: (ClassicalRegister, Int)? = nil

    public var description: String {
        return ""
    }

    /**
     Create a new instruction.
     
     - parameter name: instruction name string
     - parameter param: list of real parameters
     - parameter arg: list InstructionArgument
     */
    public init(_ name: String, _ params: [Double], _ args: [RegisterArgument]) {
        self.name = name
        self.params = params
        self.args = args
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
    public func c_if(_ classical: ClassicalRegister, _ val: Int) throws -> Instruction {
        if val < 0 {
            throw QISKitException.controlValueNegative
        }
        self.control = (classical, val)
        return self
    }

    /**
     Apply any modifiers of this instruction to another one.
     */
    func _modifiers(gate: Gate) throws {
        if self.control != nil {
            try self.check_circuit()
            if !gate.circuit!.has_register(self.control!.0) {
                throw QISKitException.controlregnotfound(name: self.control!.0.name)
            }
            let _ = try gate.c_if(self.control!.0, self.control!.1)
        }
    }

    /**
     Print an if statement if needed.
     */
    func _qasmif(_ string: String) -> String {
        //TODO: validate is the var String is correct
        if self.control == nil {
            return string
        }
        return "if(\(self.control!.0.name)==\(self.control!.1)) \(string)"
    }
}
