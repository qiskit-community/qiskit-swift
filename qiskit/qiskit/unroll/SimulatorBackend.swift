//
//  SimulatorBackend.swift
//  qiskit
//
//  Created by Manoel Marques on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Backend for the unroller that composes qasm into simulator inputs.
 Author: Jay Gambetta and Andrew Cross
 The input is a AST and a basis set and returns a compiled simulator circuit
 ready to be run in backends:
     [
     "local_unitary_simulator",
     "local_qasm_simulator"
     ]
     OUTPUT
         compiled_circuit =
         {
         'number_of_qubits': 2,
         'number_of_cbits': 2,
         'number_of_operations': 4
         'qubit_order': {('q', 0): 0, ('v', 0): 1}
         'cbit_order': {('c', 1): 1, ('c', 0): 0},
         'qasm':
             [{
             'name': 'U',
             'theta': 1.570796326794897
             'phi': 1.570796326794897
             'lambda': 1.570796326794897
             'qubit_indices': [0],
             'gate_size': 1,
             },
             {
             'name': 'CX',
             'qubit_indices': [0, 1],
             'gate_size': 2,
             },
             {
             'name': 'reset',
             'qubit_indices': [1]
             },
             {
             'name': 'measure',
             'cbit_indices': [0],
             'qubit_indices': [0]
             }],
         }
 */
/**
# TODO: currently only supports standard basis
# TODO: currently if gates are not supported
# TODO: think more about compiled_circuit dictionary i would like to have this
# langugage agnoistic and a complete representation of a quantum file for any
# simulator so some things to consider are remove 'number_of_operations',
# as it is just he lenght of qasm.
#
# Current thinking for conditionals is to add
#
# 'condition_type': 'equality',
# 'condition_cbits': [0,2,3],
# 'condition_value': 7,
#
# to the elements of qasm.
#
*/
final class SimulatorBackend: UnrollerBackend {

    private var circuit: [String:AnyObject] = [:]
    private var _number_of_qubits: Int = 0
    private var _number_of_cbits: Int = 0
    private var _qubit_order: [RegBit:Int] = [:]
    private var _cbit_order: [RegBit:Int] = [:]
    private var _operation_order: Int = 0
    private let prec: Int = 15
    private var creg:RegBit? = nil
    private var cval:Int? = nil
    private var gates: [String:GateData] = [:]
    private var trace: Bool = false
    private var basis: [String]
    private var listen: Bool = true
    private var in_gate: String = ""
    private var printed_gates: [String] = []

   /**
     Setup this backend.
     basis is a list of operation name strings.
     */
    init(_ basis: [String] = []) {
        self.circuit["qasm"] = [] as AnyObject
        self.basis = basis
    }

    /**
     Set trace to True to enable
     */
    func set_trace(trace: Bool) {
        self.trace = trace
    }

    /**
     Declare the set of user-defined gates to emit.
     basis is a list of operation name strings.
     */
    func set_basis(_ basis: [String]) {
        self.basis = basis
    }

    /**
     Format a float f as a string with self.prec digits.
     */
    private func _fs(_ number: Double) -> String {
        let format = "%.\(self.prec)f"
        return String(format:format,number)
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
        assert(size >= 0, "invalid qreg size")
        for j in 0..<size {
            self._qubit_order[RegBit(name, j)] = self._number_of_qubits + j
        }
        self._number_of_qubits += size
        self.circuit["number_of_qubits"] = self._number_of_qubits as AnyObject
        self.circuit["qubit_order"] = self._qubit_order as AnyObject
        if self.trace {
            print("added \(size) qubits from qreg \(name) giving a total of \(self._number_of_qubits) qubits")
        }
    }

    /**
     Create a new classical register.
     name = name of the register
     sz = size of the register
     */
    func new_creg(_ name: String, _ size: Int) throws {
        assert(size >= 0, "invalid creg size")
        for j in 0..<size {
            self._cbit_order[RegBit(name, j)] = self._number_of_cbits + j
        }
        self._number_of_cbits += size
        self.circuit["number_of_cbits"] = self._number_of_cbits as AnyObject
        self.circuit["cbit_order"] = self._cbit_order as AnyObject
        if self.trace {
            print("added \(size) cbits from creg \(name) giving a total of \(self._number_of_cbits) cbits")
        }
    }

    /**
     Define a new quantum gate.
     name is a string.
     gatedata is the AST node for the gate.
     */
    func define_gate(_ name: String, _ gatedata: GateData) throws {
        self.gates[name] = gatedata
    }

    /**
     Fundamental single qubit gate.
     arg is 3-tuple of float parameters.
     qubit is (regname,idx) tuple.
     */
    func u(_ arg: (Double, Double, Double), _ qubit: RegBit) throws {
        if self.listen {
            if !self.basis.contains("U") {
                self.basis.append("U")
            }
            if self.trace {
                if let reg = self.creg {
                    if let val = self.cval {
                        print("if(\(reg.name)==\(val)) ")
                    }
                }
                print("U(\(self._fs(arg.0)),\(self._fs(arg.1)),\(self._fs(arg.2))) \(qubit.description);")
            }
            if self.creg != nil {
                throw BackendException.ifnotsupported
            }
            let qubit_indices = [self._qubit_order[qubit]!]
            self._operation_order += 1
            self.circuit["number_of_operations"] = self._operation_order as AnyObject
            var array: [AnyObject] = self.circuit["qasm"] as! [AnyObject]
            array.append([
                "gate_size" : 1,
                "name" : "U",
                "theta" : arg.0,
                "phi" : arg.1,
                "lambda" : arg.2,
                "qubit_indices": qubit_indices
                ] as AnyObject)
            self.circuit["qasm"] = array as AnyObject
        }
    }

    /**
     Fundamental two qubit gate.
     qubit0 is (regname,idx) tuple for the control qubit.
     qubit1 is (regname,idx) tuple for the target qubit.
     */
    func cx(_ qubit0: RegBit, _ qubit1: RegBit) throws {
        if self.listen {
            if !self.basis.contains("CX") {
                self.basis.append("CX")
            }
            if self.trace {
                if let reg = self.creg {
                    if let val = self.cval {
                        print("if(\(reg.name)==\(val)) ")
                    }
                }
                print("CX \(qubit0.description),\(qubit1.description);")
            }
            if self.creg != nil {
                throw BackendException.ifnotsupported
            }
            let qubit_indices = [self._qubit_order[qubit0]!, self._qubit_order[qubit1]!]
            self._operation_order += 1
            self.circuit["number_of_operations"] = self._operation_order as AnyObject
            var array: [AnyObject] = self.circuit["qasm"] as! [AnyObject]
            array.append([
                "gate_size": 2,
                "name": "CX",
                "qubit_indices": qubit_indices,
                ] as AnyObject)
            self.circuit["qasm"] = array as AnyObject
        }
    }

    /**
     Measurement operation.
     qubit is (regname, idx) tuple for the input qubit.
     bit is (regname, idx) tuple for the output bit.
     */
    func measure(_ qubit: RegBit, _ cbit: RegBit) throws {
        self._operation_order += 1
        self.circuit["number_of_operations"] = self._operation_order as AnyObject
        let qubit_indices = [self._qubit_order[qubit]!]
        let cbit_indices = [self._cbit_order[cbit]!]
        var array: [AnyObject] = self.circuit["qasm"] as! [AnyObject]
        array.append([
            "name": "measure",
            "qubit_indices": qubit_indices,
            "cbit_indices": cbit_indices
        ] as AnyObject)
        self.circuit["qasm"] = array as AnyObject
        if self.trace {
            print("measure \(qubit.description) -> \(cbit.description);")
        }
    }

    /**
     Barrier instruction.
     qubitlists is a list of lists of (regname, idx) tuples.
     */
    func barrier(_ qubitlists: [[RegBit]]) throws {
        // ignore barriers
    }

    /**
     Reset instruction.
     qubit is a (regname, idx) tuple.
     */
    func reset(_ qubit: RegBit) throws {
        self._operation_order += 1
        self.circuit["number_of_operations"] = self._operation_order as AnyObject
        let qubit_indices = [self._qubit_order[qubit]!]
        var array: [AnyObject] = self.circuit["qasm"] as! [AnyObject]
        array.append([
            "name": "reset",
            "qubit_indices" : qubit_indices
        ] as AnyObject)
        self.circuit["qasm"] = array as AnyObject
        if self.trace {
            print("reset \(qubit.description);")
        }
    }

    /**
     Attach a current condition.
     creg is a name string.
     cval is the integer value for the test.
     */
    func set_condition(_ creg: RegBit, _ cval: Int) {
        self.creg = creg
        self.cval = cval
    }

    /**
     Drop the current condition.
     */
    func drop_condition() {
        self.creg = nil
        self.cval = nil
    }

    /**
     Begin a custom gate.
     name is name string.
     args is list of floating point parameters.
     qubits is list of (regname, idx) tuples.
     */
    func start_gate(_ name: String, _ args: [Double], _ qubits: [RegBit]) throws {
        var sargs: [String] = []
        for arg in args {
            sargs.append(self._fs(arg))
        }
        var squbits: [String] = []
        for qubit in qubits {
            squbits.append(qubit.description)
        }
        if self.listen && self.trace && !self.basis.contains(name) {
            print("// start \(name), \(sargs.joined(separator:",")), \(squbits.joined(separator:","))")
        }
        if self.listen && !self.basis.contains(name) {
            if let gate = self.gates[name] {
                if gate.opaque {
                    throw BackendException.erroropaque(name: name)
                }
            }
        }
        if self.listen && self.basis.contains(name) {
            self.in_gate = name
            self.listen = false
            if self.trace {
                if let reg = self.creg {
                    if let val = self.cval {
                        print("if(\(reg.name)==\(val)) ")
                    }
                }
                print(name)
                if !sargs.isEmpty {
                    print("\(sargs.joined(separator:","))")
                }
                print(" \(squbits.joined(separator:","));")
            }
            if self.creg != nil {
                throw BackendException.ifnotsupported
            }
            // TODO: update here for any other gates, like h, u1, u2, u3, but
            // need to decided how we handle the matrix.
        }
    }

    /**
     End a custom gate.
     name is name string.
     args is list of floating point parameters.
     qubits is list of (regname, idx) tuples.
     */
    func end_gate(_ name: String, _ args: [Double], _ qubits: [RegBit]) {
        if name == self.in_gate {
            self.in_gate = ""
            self.listen = true
        }
        if self.listen && self.trace && !self.basis.contains(name) {
            var sargs: [String] = []
            for arg in args {
                sargs.append(self._fs(arg))
            }
            var squbits: [String] = []
            for qubit in qubits {
                squbits.append(qubit.description)
            }
            print("// end \(name), \(sargs.joined(separator:",")), \(squbits.joined(separator:","))")
        }
    }
}
