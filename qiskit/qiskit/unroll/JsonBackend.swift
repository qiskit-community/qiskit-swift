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
 Backend for the unroller that composes qasm into json file.

 The input is a AST and a basis set and returns a json memory object

 [
     "header": [
         "number_of_qubits": 2, // int
         "number_of_clbits": 2, // int
         "qubit_labels": [["q", 0], ["v", 0]], // list[list[string, int]]
         "clbit_labels": [["c", 2]], // list[list[string, int]]
     ]
     "operations": // list[map]
     [
         [
             "name": , // required -- string
             "params": , // optional -- list[double]
             "qubits": , // optional -- list[int]
             "cbits": , //optional -- list[int]
             "conditional":  // optional -- map
             [
                 "type": "equals", // string
                 "mask": "0xHexadecimalString", // big int
                 "val":  "0xHexadecimalString", // big int
             ]
         ],
     ]
 ]
 */
final class JsonBackend: UnrollerBackend {

    private var circuit: [String:Any] = [:]
    private var _number_of_qubits: Int = 0
    private var _number_of_cbits: Int = 0
    private var _qubit_order: [RegBit] = []
    private var _cbit_order: [RegBit] = []
    private var _qubit_order_internal: [RegBit:Int] = [:]
    private var _cbit_order_internal: [RegBit:Int] = [:]
    private var creg:String? = nil
    private var cval:Int? = nil
    private var gates: [String:GateData] = [:]
    private var basis: [String]
    private var listen: Bool = true
    private var in_gate: String = ""
    private var printed_gates: [String] = []

    /**
     Setup this backend.
     basis is a list of operation name strings.
     The default basis is ["U", "CX"].
     */
    init(_ basis: [String] = []) {
        self.circuit["operations"] = []
        self.circuit["header"] = [:]
        // default, unroll to U, CX
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
        assert(size >= 0, "invalid qreg size")

        for j in 0..<size {
            self._qubit_order.append(RegBit(name, j))
            self._qubit_order_internal[RegBit(name, j)] = self._number_of_qubits + j
        }
        self._number_of_qubits += size
        var header: [String:Any] = [:]
        if let head = self.circuit["header"] as? [String:Any] {
            header = head
        }
        header["number_of_qubits"] = self._number_of_qubits
        header["qubit_labels"] = self._qubit_order.map { [$0.name,$0.index] }
        self.circuit["header"] = header
    }

    /**
     Create a new classical register.
     name = name of the register
     sz = size of the register
     */
    func new_creg(_ name: String, _ size: Int) throws {
        assert(size >= 0, "invalid creg size")

        self._cbit_order.append(RegBit(name, size))
        for j in 0..<size {
            self._cbit_order_internal[RegBit(name, j)] = self._number_of_cbits + j
        }
        self._number_of_cbits += size
        var header: [String:Any] = [:]
        if let head = self.circuit["header"] as? [String:Any] {
            header = head
        }
        header["number_of_clbits"] = self._number_of_cbits
        header["clbit_labels"] = self._cbit_order.map { [$0.name,$0.index] }
        self.circuit["header"] = header
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

     arg is 3-tuple of Node expression objects.
     qubit is (regname,idx) tuple.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func u(_ arg: (NodeRealValueProtocol, NodeRealValueProtocol, NodeRealValueProtocol), _ qubit: RegBit, _ nested_scope:[[String:NodeRealValueProtocol]]?) throws {
        if self.listen {
            if !self.basis.contains("U") {
                self.basis.append("U")
            }
            let qubit_indices: [Int] =  [self._qubit_order_internal[qubit]!]
            var operations: [[String:Any]] = []
            if let oper = self.circuit["operations"] as? [[String:Any]] {
                operations = oper
            }
            var operation: [String:Any] = [:]
            operation["name"] = "U"
            operation["params"] = [try arg.0.real(nested_scope),try arg.1.real(nested_scope),try arg.2.real(nested_scope)]
            operation["qubits"] = qubit_indices
            operations.append(operation)
            self.circuit["operations"] = operations
            self._add_condition()
        }
    }

    /**
     Check for a condition (self.creg) and add fields if necessary.
     Fields are added to the last operation in the circuit.
     */
    private func _add_condition() {
        if self.creg != nil {
            var mask: Int = 0
            let conditional: [String:Any] = [:]
            for (cbit, index) in self._cbit_order_internal {
                if cbit.name == self.creg! {
                    mask |= (1 << index)
                }
                // Would be nicer to zero pad the mask, but we
                // need to know the total number of cbits.
                // format_spec = "{0:#0{%d}X}" % number_of_clbits
                // format_spec.format(mask)
                var conditional: [String:Any] = [:]
                conditional["type"] = "equals"
                conditional["mask"] = String(format: "0x%X", mask)
                conditional["val"] = String(format: "0x%X", self.cval!)
            }
            if var operations = self.circuit["operations"] as? [[String:Any]] {
                if var operation = operations.last {
                    operation["conditional"] = conditional
                    operations[operations.count-1] = operation
                    self.circuit["operations"] = operations
                }
            }
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
           let qubit_indices: [Int] =  [self._qubit_order_internal[qubit0]!,self._qubit_order_internal[qubit1]!]
            var operations: [[String:Any]] = []
            if let oper = self.circuit["operations"] as? [[String:Any]] {
                operations = oper
            }
            var operation: [String:Any] = [:]
            operation["name"] = "CX"
            operation["qubits"] = qubit_indices
            operations.append(operation)
            self.circuit["operations"] = operations
            self._add_condition()
        }
    }

    /**
     Measurement operation.
     qubit is (regname, idx) tuple for the input qubit.
     bit is (regname, idx) tuple for the output bit.
     */
    func measure(_ qubit: RegBit, _ bit: RegBit) throws {
        if self.listen {
            if !self.basis.contains("measure") {
                self.basis.append("measure")
            }
            let qubit_indices: [Int] =  [self._qubit_order_internal[qubit]!]
            let clbit_indices: [Int] =  [self._cbit_order_internal[bit]!]
            var operations: [[String:Any]] = []
            if let oper = self.circuit["operations"] as? [[String:Any]] {
                operations = oper
            }
            var operation: [String:Any] = [:]
            operation["name"] = "measure"
            operation["qubits"] = qubit_indices
            operation["clbits"] = clbit_indices
            operations.append(operation)
            self.circuit["operations"] = operations
            self._add_condition()
        }
    }

    /**
     Barrier instruction.
     qubitlists is a list of lists of (regname, idx) tuples.
     */
    func barrier(_ qubitlists: [[RegBit]]) throws {
        if self.listen {
            if !self.basis.contains("barrier") {
                self.basis.append("barrier")
            }
            var qubit_indices: [Int] =  []
            for qubitlist in qubitlists {
                for qubits in qubitlist {
                    qubit_indices.append(self._qubit_order_internal[qubits]!)
                }
            }
            var operations: [[String:Any]] = []
            if let oper = self.circuit["operations"] as? [[String:Any]] {
                operations = oper
            }
            var operation: [String:Any] = [:]
            operation["name"] = "barrier"
            operation["qubits"] = qubit_indices
            operations.append(operation)
            self.circuit["operations"] = operations
            // no conditions on barrier, even when it appears
            // in body of conditioned gate
        }
    }

    /**
     Reset instruction.
     qubit is a (regname, idx) tuple.
     */
    func reset(_ qubit: RegBit) throws {
        if self.listen {
            if !self.basis.contains("reset") {
                self.basis.append("reset")
            }
            let qubit_indices: [Int] =  [self._qubit_order_internal[qubit]!]
            var operations: [[String:Any]] = []
            if let oper = self.circuit["operations"] as? [[String:Any]] {
                operations = oper
            }
            var operation: [String:Any] = [:]
            operation["name"] = "reset"
            operation["qubits"] = qubit_indices
            operations.append(operation)
            self.circuit["operations"] = operations
            self._add_condition()
        }
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
    func start_gate(_ name: String, _ args: [NodeRealValueProtocol], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValueProtocol]]?) throws {
        if self.listen && !self.basis.contains(name) {
            if let gate = self.gates[name] {
                if gate.opaque {
                    throw BackendError.errorOpaque(name: name)
                }
            }
        }
        if self.listen && self.basis.contains(name) {
            self.in_gate = name
            self.listen = false
            var qubit_indices: [Int] =  []
            for qubit in qubits {
                qubit_indices.append(self._qubit_order_internal[qubit]!)
            }
            var operations: [[String:Any]] = []
            if let oper = self.circuit["operations"] as? [[String:Any]] {
                operations = oper
            }
            var operation: [String:Any] = [:]
            operation["name"] = name
            var params: [Double] = []
            for arg in args {
                params.append(try arg.real(nested_scope))
            }
            operation["params"] = params
            operation["qubits"] = qubit_indices
            operations.append(operation)
            self.circuit["operations"] = operations
            self._add_condition()
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
    func end_gate(_ name: String, _ args: [NodeRealValueProtocol], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValueProtocol]]?) throws {
        if name == self.in_gate {
            self.in_gate = ""
            self.listen = true
        }
    }

    /**
     Returns the generated circuit.
     */
    func get_output() throws -> Any? {
        assert(self._is_circuit_valid(), "Invalid circuit! Has the Qasm parsing been called?. e.g: unroller.execute()")
        if JSONSerialization.isValidJSONObject(self.circuit) {
            return self.circuit
        }
        throw UnrollerError.invalidJSON
    }

    /**
     Checks whether the circuit object is a valid one or not.
     */
    private func _is_circuit_valid() -> Bool {
        guard let header = self.circuit["header"] as? [String:Any] else {
            return false
        }
        guard let operations = self.circuit["operations"] as? [[String:Any]] else {
            return false
        }
        return !header.isEmpty && !operations.isEmpty
    }
}
