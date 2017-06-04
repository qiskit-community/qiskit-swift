//
//  Instruction.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Generic quantum computer instruction.
 */
public class Instruction: CustomStringConvertible {

    let name: String
    var params: [Double]
    let args: [RegisterArgument]
    var circuit: QuantumCircuit? = nil
    private var control: (ClassicalRegister, Int)? = nil

    public var description: String {
        preconditionFailure("description not implemented")
    }

    public var qasm: String {
        return self.description
    }

    /**
     Create a new instruction.
     
     - parameter name: instruction name string
     - parameter param: list of real parameters
     - parameter arg: list InstructionArgument
     */
    public init(_ name: String, _ params: [Double], _ args: [RegisterArgument], _ circuit: QuantumCircuit?) {
        if type(of: self) == Instruction.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = name
        self.params = params
        self.args = args
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
    public func c_if(_ classical: ClassicalRegister, _ val: Int) throws -> Instruction {
        if val < 0 {
            throw QISKitException.controlValueNegative
        }
        self.control = (classical, val)
        return self
    }

    public func q_if(_ qregs:[QuantumRegister]) -> Instruction {
        preconditionFailure("q_if not implemented")
    }

    /**
     Apply any modifiers of this instruction to another one.
     */
    public func _modifiers(_ instruction: Instruction) throws {
        if self.control != nil {
            try self.check_circuit()
            if !instruction.circuit!.has_register(self.control!.0) {
                throw QISKitException.controlregnotfound(name: self.control!.0.name)
            }
            let _ = try instruction.c_if(self.control!.0, self.control!.1)
        }
    }

    /**
     Print an if statement if needed.
     */
    public func _qasmif(_ string: String) -> String {
        if self.control == nil {
            return string
        }
        return "if(\(self.control!.0.name)==\(self.control!.1)) \(string)"
    }

    public func inverse() -> Instruction {
        preconditionFailure("inverse not implemented")
    }

    public func reapply(_ circ: QuantumCircuit) throws {
        preconditionFailure("reapply not implemented")
    }
}
