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
Contains a (slow) Python simulator that returns the unitary of the circuit.

Author: Jay Gambetta and John Smolin

It simulates a unitary of a quantum circuit that has been compiled to run on
the simulator. It is exponential in the number of qubits.

The input is the circuit object and the output is the same circuit object with
a result field added results['data']['unitary'] where the unitary is
a 2**n x 2**n complex numpy array representing the unitary matrix.


The input is
compiled_circuit object
and the output is the results object

The simulator is run using

UnitarySimulator(compiled_circuit).run().

In the qasm, key operations with type 'measure' and 'reset' are dropped.

Internal circuit_object

compiled_circuit =
{
    "header": {
        "number_of_qubits": 2, // int
        "number_of_clbits": 2, // int
        "qubit_labels": [["q", 0], ["v", 0]], // list[list[string, int]]
        "clbit_labels": [["c", 2]], // list[list[string, int]]
    }
    "operations": // list[map]
    [
    {
    "name": , // required -- string
    "params": , // optional -- list[double]
    "qubits": , // optional -- list[int]
    "clbits": , //optional -- list[int]
    "conditional":  // optional -- map
    {
    "type": , // string
    "mask": , // big int
    "val":  , // big int
    }
    },
    ]
}

returned results object

result =
    {
        'data':
        {
            'unitary': np.array([[ 0.70710678 +0.00000000e+00j
            0.70710678 -8.65956056e-17j
            0.00000000 +0.00000000e+00j
            0.00000000 +0.00000000e+00j]
            [ 0.00000000 +0.00000000e+00j
            0.00000000 +0.00000000e+00j
            0.70710678 +0.00000000e+00j
            -0.70710678 +8.65956056e-17j]
            [ 0.00000000 +0.00000000e+00j
            0.00000000 +0.00000000e+00j
            0.70710678 +0.00000000e+00j
            0.70710678 -8.65956056e-17j]
            [ 0.70710678 +0.00000000e+00j
            -0.70710678 +8.65956056e-17j
            0.00000000 +0.00000000e+00j
            0.00000000 +0.00000000e+00j]
            }
            'state': 'DONE'
            }
*/

//# TODO add ["status"] = 'DONE', 'ERROR' especitally for empty circuit error
//# does not show up
final class UnitarySimulator: Simulator {

    static let __configuration: [String:Any] = [
        "name": "local_unitary_simulator",
        "url": "https://github.com/IBM/qiskit-sdk-py",
        "simulator": true,
        "description": "A cpp simulator for qasm files",
        "nQubits": 10,
        "couplingMap": "all-to-all",
        "gateset": "SU2+CNOT"
    ]

    private(set) var circuit: [String:Any] = [:]
    private var _number_of_qubits: Int = 0
    private var result: [String:Any] = [:]
    private var _unitary_state: [[Complex]] = []
    private var _number_of_operations: Int = 0

    init(_ job: [String:Any]) throws {
        if let compiled_circuit = job["compiled_circuit"] as? String {
            if let data = compiled_circuit.data(using: .utf8) {
                let jsonAny = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let json = jsonAny as? [String:Any] {
                    self.circuit = json
                }
            }
        }
        if let header = self.circuit["header"]  as? [String:Any] {
            if let number_of_qubits = header["number_of_qubits"] as? Int {
                self._number_of_qubits = number_of_qubits
            }
        }
        self.result["data"] = [:]
        self._unitary_state = NumUtilities.identityComplex(Int(pow(2.0,Double(self._number_of_qubits))))
        if let operations = self.circuit["operations"]  as? [[String:Any]] {
            self._number_of_operations = operations.count
        }
    }

    /**
     Apply the single-qubit gate.

     gate is the single-qubit gate.
     qubit is the qubit to apply it on counts from 0 and order
     is q_{n-1} ... otimes q_1 otimes q_0.
     number_of_qubits is the number of qubits in the system.
     */
    private func _add_unitary_single(_ gate: [[Complex]], _ qubit: Int) {
        let unitaty_add = SimulatorTools.enlarge_single_opt(gate, qubit, self._number_of_qubits)
        self._unitary_state = NumUtilities.dotComplex(unitaty_add, self._unitary_state)
    }

    /**
     Apply the two-qubit gate.

     gate is the two-qubit gate
     q0 is the first qubit (control) counts from 0
     q1 is the second qubit (target)
     returns a complex numpy array
     */
    private func _add_unitary_two(_ gate: [[Complex]], _ q0: Int, _ q1: Int) {
        let unitaty_add = SimulatorTools.enlarge_two_opt(gate, q0, q1, self._number_of_qubits)
        self._unitary_state = NumUtilities.dotComplex(unitaty_add, self._unitary_state)
    }

    /**
     Apply the single-qubit gate.
     */
    func run() throws -> [String:Any] {
        if let operations = self.circuit["operations"] as? [[String:Any]] {
            for j in 0..<self._number_of_operations {
                // each operation
                let operation = operations[j]
                guard let name = operation["name"] as? String else {
                    self.result["status"] = "ERROR"
                    return self.result
                }
                if name == "U" {
                    if let qubits = operation["qubits"] as? [Int] {
                        if let params = operation["params"] as? [Double] {
                            let qubit = qubits[0]
                            let theta = params[0]
                            let phi = params[1]
                            let lam = params[2]
                            let gate: [[Complex]] = [
                                    [
                                        Complex(real:cos(theta/2.0)),
                                        Complex(imag: lam).exp() * -sin(theta/2.0)
                                    ],
                                    [
                                        Complex(imag: phi).exp() * sin(theta/2.0),
                                        (Complex(imag: phi) + Complex(imag: lam)).exp() * cos(theta/2.0)
                                    ]
                            ]
                            self._add_unitary_single(gate, qubit)
                        }
                    }
                }
                else if name == "CX" {
                    if let qubits = operation["qubits"] as? [Int] {
                        let gate: [[Complex]] = [[1, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 1, 0, 0]]
                        self._add_unitary_two(gate, qubits[0], qubits[1])
                    }
                }
                else if name == "measure" {
                    print("Warning have dropped measure from unitary simulator")
                }
                else if name == "reset" {
                print("Warning have dropped reset from unitary simulator")
                }
                else if name == "barrier" {
                }
                else {
                    self.result["status"] = "ERROR"
                    return self.result
                }
            }
        }
        var data: [String:Any] = [:]
        data["unitary"] = self._unitary_state
        self.result["data"] = data
        self.result["status"] = "DONE"
        return self.result
    }
}
