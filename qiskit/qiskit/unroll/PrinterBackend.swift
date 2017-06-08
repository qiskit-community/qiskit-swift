//
//  PrinterBackend.swift
//  qiskit
//
//  Created by Manoel Marques on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class PrinterBackend: UnrollerBackend { 

    /**
     Declare the set of user-defined gates to emit.
     basis is a list of operation name strings.
     */
    func set_basis(_ basis: [String]) {

    }

    /**
     Print the version string.
     v is a version number.
     */
    func version(_ version: String) {

    }
    /**
     Create a new quantum register.
     name = name of the register
     sz = size of the register
     */
    func new_qreg(_ name: String, _ size: Int) throws {

    }

    /**
     Create a new classical register.
     name = name of the register
     sz = size of the register
     */
    func new_creg(_ name: String, _ size: Int) throws {

    }

    /**
     Define a new quantum gate.
     name is a string.
     gatedata is the AST node for the gate.
     */
    func define_gate(_ name: String, _ gatedata: GateData) throws {

    }

    /**
     Fundamental single qubit gate.
     arg is 3-tuple of float parameters.
     qubit is (regname,idx) tuple.
     */
    func u(_ arg: (Double, Double, Double), _ qubit: RegBit) throws {

    }

    /**
     Fundamental two qubit gate.
     qubit0 is (regname,idx) tuple for the control qubit.
     qubit1 is (regname,idx) tuple for the target qubit.
     */
    func cx(_ qubit0: RegBit, _ qubit1: RegBit) throws {

    }

    /**
     Measurement operation.
     qubit is (regname, idx) tuple for the input qubit.
     bit is (regname, idx) tuple for the output bit.
     */
    func measure(_ qubit: RegBit, _ bit: RegBit) throws {

    }

    /**
     Barrier instruction.
     qubitlists is a list of lists of (regname, idx) tuples.
     */
    func barrier(_ qubitlists: [[RegBit]]) throws {

    }

    /**
     Reset instruction.
     qubit is a (regname, idx) tuple.
     */
    func reset(_ qubit: RegBit) throws {

    }

    /**
     Attach a current condition.
     creg is a name string.
     cval is the integer value for the test.
     */
    func set_condition(_ creg: RegBit, _ cval: Int) {

    }

    /**
     Drop the current condition.
     */
    func drop_condition() {

    }

    /**
     Begin a custom gate.
     name is name string.
     args is list of floating point parameters.
     qubits is list of (regname, idx) tuples.
     */
    func start_gate(_ name: String, _ args: [Double], _ qubits: [RegBit]) throws {

    }

    /**
     End a custom gate.
     name is name string.
     args is list of floating point parameters.
     qubits is list of (regname, idx) tuples.
     */
    func end_gate(_ name: String, _ args: [Double], _ qubits: [RegBit]) {
    
    }
}
