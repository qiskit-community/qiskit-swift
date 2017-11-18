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
#if os(Linux)
import Dispatch
#endif

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
    "qubits": , // required -- list[int]
    "clbits": , //optional -- list[int]
    "conditional":  // optional -- map
    {
    "type": , // string
    "mask": , // hex string
    "val":  , // bhex string
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
final class UnitarySimulator: BaseBackend {

    private var _number_of_qubits: Int = 0
    private var _unitary_state: [[Complex]] = []

    public required init(_ configuration: [String:Any]? = nil) {
        super.init(configuration)
        if let conf = configuration {
            self._configuration = conf
        }
        else {
            self._configuration = [
                "name": "local_unitary_simulator",
                "url": "https://github.com/IBM/qiskit-sdk-swift",
                "simulator": true,
                "local": true,
                "description": "A swift simulator for unitary matrix",
                "coupling_map": "all-to-all",
                "basis_gates": "u1,u2,u3,cx,id"
            ]
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
     Run circuits in qobj
     */
    @discardableResult
    override public func run(_ q_job: QuantumJob, response: @escaping ((_:Result) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        DispatchQueue.global().async {
            var result = Result()
            let job_id = UUID().uuidString
            do {
                let qobj = q_job.qobj
                var result_list: [[String:Any]] = []
                if let circuits = qobj["circuits"] as? [[String:Any]] {
                    for circuit in circuits {
                        result_list.append(try self.run_circuit(circuit))
                    }
                }
                result = Result(["job_id": job_id, "result": result_list, "status": "COMPLETED"],qobj)
            } catch {
                result = Result(["job_id": job_id, "status": "ERROR","result": error.localizedDescription],q_job.qobj)
            }
            DispatchQueue.main.async {
                response(result)
            }
        }
        return reqTask
    }

    /**
     Apply the single-qubit gate.
     */
    private func run_circuit(_ circuit: [String:Any]) throws -> [String:Any] {
        var result: [String:Any] = [:]
        result["data"] = [:]
        guard let ccircuit = circuit["compiled_circuit"] as? [String:Any] else {
            throw SimulatorError.missingCompiledCircuit
        }
        if let header = ccircuit["header"]  as? [String:Any] {
            if let number_of_qubits = header["number_of_qubits"] as? Int {
                self._number_of_qubits = number_of_qubits
            }
        }
        self._unitary_state = NumUtilities.identityComplex(Int(pow(2.0,Double(self._number_of_qubits))))
        guard let operations = ccircuit["operations"] as? [[String:Any]] else {
            result["status"] = "ERROR"
            return result
        }
        for operation in operations {
            guard let name = operation["name"] as? String else {
                throw SimulatorError.missingOperationName
            }
            if ["U", "u1", "u2", "u3"].contains(name) {
                if let qubits = operation["qubits"] as? [Int] {
                    var params: [Double]? = nil
                    if let _params = operation["params"] as? [Double] {
                        params = _params
                    }
                    let qubit = qubits[0]
                    let gate = SimulatorTools.single_gate_matrix(name, params)
                    self._add_unitary_single(gate, qubit)
                }
            }
            else if ["id", "u0"].contains(name) {
            }
            else if ["CX", "cx"].contains(name) {
                if let qubits = operation["qubits"] as? [Int] {
                    let gate: [[Complex]] = [[1, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 1, 0, 0]]
                    self._add_unitary_two(gate, qubits[0], qubits[1])
                }
            }
            else if name == "measure" {
                SDKLogger.logInfo("Warning have dropped measure from unitary simulator")
            }
            else if name == "reset" {
                SDKLogger.logInfo("Warning have dropped reset from unitary simulator")
            }
            else if name == "barrier" {
            }
            else {
                 throw SimulatorError.unrecognizedOperation(backend: self.configuration["name"] as! String, operation: name)
            }
        }
        var data: [String:Any] = [:]
        data["unitary"] = self._unitary_state
        result["data"] = data
        result["status"] = "DONE"
        return result
    }
}
