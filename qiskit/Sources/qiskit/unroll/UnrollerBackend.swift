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
 Backend for the unroller.
 This backend also serves as a base for other unroller backends.
 */
protocol UnrollerBackend {

    /**
     Declare the set of user-defined gates to emit.
     basis is a list of operation name strings.
     */
    func set_basis(_ basis: [String])

    /**
     Print the version string.
     v is a version number.
     */
    func version(_ version: String)
    /**
     Create a new quantum register.
     name = name of the register
     sz = size of the register
     */
    func new_qreg(_ name: String, _ size: Int) throws

    /**
     Create a new classical register.
     name = name of the register
     sz = size of the register
     */
    func new_creg(_ name: String, _ size: Int) throws

    /**
     Define a new quantum gate.
     name is a string.
     gatedata is the AST node for the gate.
     */
    func define_gate(_ name: String, _ gatedata: GateData) throws

    /**
     Fundamental single qubit gate.

     arg is 3-tuple of Node expression objects.
     qubit is (regname,idx) tuple.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func u(_ arg: (NodeRealValueProtocol, NodeRealValueProtocol, NodeRealValueProtocol), _ qubit: RegBit, _ nested_scope:[[String:NodeRealValueProtocol]]?) throws

    /**
     Fundamental two qubit gate.
     qubit0 is (regname,idx) tuple for the control qubit.
     qubit1 is (regname,idx) tuple for the target qubit.
     */
    func cx(_ qubit0: RegBit, _ qubit1: RegBit) throws

    /**
     Measurement operation.
     qubit is (regname, idx) tuple for the input qubit.
     bit is (regname, idx) tuple for the output bit.
     */
    func measure(_ qubit: RegBit, _ bit: RegBit) throws

    /**
     Barrier instruction.
     qubitlists is a list of lists of (regname, idx) tuples.
     */
    func barrier(_ qubitlists: [[RegBit]]) throws

    /**
     Reset instruction.
     qubit is a (regname, idx) tuple.
    */
    func reset(_ qubit: RegBit) throws

    /**
     Attach a current condition.
     creg is a name string.
     cval is the integer value for the test.
     */
    func set_condition(_ creg: String, _ cval: Int)

    /**
     Drop the current condition.
     */
    func drop_condition()

    /**
     Begin a custom gate.

     name is name string.
     args is list of Node expression objects.
     qubits is list of (regname, idx) tuples.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func start_gate(_ name: String, _ args: [NodeRealValueProtocol], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValueProtocol]]?) throws

    /**
     End a custom gate.

     name is name string.
     args is list of Node expression objects.
     qubits is list of (regname, idx) tuples.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth..
     */
    func end_gate(_ name: String, _ args: [NodeRealValueProtocol], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValueProtocol]]?) throws

    /**
     Returns the generated circuit.
     */
    func get_output() throws -> Any?
}
