// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation

/**
 Backend for the unroller that creates a Circuit object
*/
final class DAGBackend: UnrollerBackend {

    private let prec: Int = 15
    private var creg:String? = nil
    private var cval:Int? = nil
    private let circuit = DAGCircuit()
    private var basis: [String]
    private var listen: Bool = true
    private var in_gate: String = ""
    private var gates: [String:GateData] = [:]

    /**
     Setup this backend.
     basis is a list of operation name strings.
     */
    init(_ basis: [String] = []) {
        self.basis = basis
    }

    /**
     Declare the set of user-defined gates to emit.
     basis is a list of operation name strings.
     */
    func set_basis(_ basis: [String]) {
        self.basis = basis
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
        try self.circuit.add_qreg(name, size)
    }

    /**
     Create a new classical register.
     name = name of the register
     sz = size of the register
     */
    func new_creg(_ name: String, _ size: Int) throws {
        try self.circuit.add_creg(name, size)
    }

    /**
     Define a new quantum gate.
     name is a string.
     gatedata is the AST node for the gate.
     */
    func define_gate(_ name: String, _ gatedata: GateData) throws {
        self.gates[name] = gatedata
        try self.circuit.add_gate_data(name, gatedata)
    }

    /**
     Fundamental single qubit gate.

     arg is 3-tuple of Node expression objects.
     qubit is (regname,idx) tuple.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func u(_ arg: (NodeRealValue, NodeRealValue, NodeRealValue), _ qubit: RegBit, _ nested_scope:[[String:NodeRealValue]]?) throws {
        if self.listen {
            var condition: RegBit? = nil
            if let reg = self.creg {
                if let val = self.cval {
                    condition = RegBit(reg,val)
                }
            }
            if !self.basis.contains("U") {
                self.basis.append("U")
                try self.circuit.add_basis_element("U", 1, 0, 3)
            }
            try self.circuit.apply_operation_back("U", [qubit], [],
                                [arg.0.real(nested_scope),
                                 arg.1.real(nested_scope),
                                 arg.2.real(nested_scope)],
                                condition)
        }
    }

    /**
     Fundamental two qubit gate.
     qubit0 is (regname,idx) tuple for the control qubit.
     qubit1 is (regname,idx) tuple for the target qubit.
     */
    func cx(_ qubit0: RegBit, _ qubit1: RegBit) throws {
        if self.listen {
            var condition: RegBit? = nil
            if let reg = self.creg {
                if let val = self.cval {
                    condition = RegBit(reg,val)
                }
            }
            if !self.basis.contains("CX") {
                self.basis.append("CX")
                try self.circuit.add_basis_element("CX", 2)
            }
            try self.circuit.apply_operation_back("CX", [qubit0, qubit1], [], [], condition)
        }
    }

    /**
     Measurement operation.
     qubit is (regname, idx) tuple for the input qubit.
     bit is (regname, idx) tuple for the output bit.
     */
    func measure(_ qubit: RegBit, _ bit: RegBit) throws {
        var condition: RegBit? = nil
        if let reg = self.creg {
            if let val = self.cval {
                condition = RegBit(reg,val)
            }
        }
        if !self.basis.contains("measure") {
            self.basis.append("measure")
            try self.circuit.add_basis_element("measure", 1, 1)
        }
        try self.circuit.apply_operation_back("measure", [qubit], [bit], [], condition)
    }

    /**
     Barrier instruction.
     qubitlists is a list of lists of (regname, idx) tuples.
     */
    func barrier(_ qubitlists: [[RegBit]]) throws {
        if self.listen {
            var names: [RegBit] = []
            for x in qubitlists {
                for reg in x {
                    names.append(reg)
                }
            }
            if !self.basis.contains("barrier") {
                self.basis.append("barrier")
                try self.circuit.add_basis_element("barrier", -1)
            }
            try self.circuit.apply_operation_back("barrier", names)
        }
    }

    /**
     Reset instruction.
     qubit is a (regname, idx) tuple.
     */
    func reset(_ qubit: RegBit) throws {
        var condition: RegBit? = nil
        if let reg = self.creg {
            if let val = self.cval {
                condition = RegBit(reg,val)
            }
        }
        if !self.basis.contains("reset") {
            self.basis.append("reset")
            try self.circuit.add_basis_element("reset", 1)
        }
        try self.circuit.apply_operation_back("reset", [qubit], [], [], condition)
    }

    /**
     Attach a current condition.
     creg is a name string.
     cval is the integer value for the test.
     */
    func set_condition(_ creg: String, _ cval: Int) {
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
     args is list of Node expression objects.
     qubits is list of (regname, idx) tuples.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func start_gate(_ name: String, _ args: [NodeRealValue], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValue]]?) throws {
        if self.listen && !self.basis.contains(name) {
            if let gate = self.gates[name] {
                if gate.opaque {
                    throw BackendError.errorOpaque(name: name)
                }
            }
        }
        if self.listen && self.basis.contains(name) {
            var condition: RegBit? = nil
            if let reg = self.creg {
                if let val = self.cval {
                    condition = RegBit(reg,val)
                }
            }
            self.in_gate = name
            self.listen = false
            try self.circuit.add_basis_element(name, qubits.count, 0, args.count)
            var params: [SymbolicValue] = []
            for arg in args {
                params.append(try arg.real(nested_scope))
            }
            try self.circuit.apply_operation_back(name, qubits, [], params, condition)
        }
    }

    /**
     End a custom gate.

     name is name string.
     args is list of Node expression objects.
     qubits is list of (regname, idx) tuples.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth..
     */
    func end_gate(_ name: String, _ args: [NodeRealValue], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValue]]?) throws {
        if name == self.in_gate {
            self.in_gate = ""
            self.listen = true
        }
    }

    /**
     Returns the generated circuit.
     */
    func get_output() throws -> Any? {
        return self.circuit
    }
}
