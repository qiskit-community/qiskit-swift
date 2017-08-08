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

final class QasmCppSimulator: Simulator {

    static let __configuration: [String:Any] = [
        "name": "local_qasm_cpp_simulator",
        "url": "https://github.com/IBM/qiskit-sdk-py",
        "simulator": true,
        "description": "A python simulator for qasm files",
        "nQubits": 10,
        "couplingMap": "all-to-all",
        "gateset": "SU2+CNOT"
    ]

    private var config: [String:Any] = [:]
    private(set) var circuit: [String:Any] = [:]
    private var _number_of_qubits: Int = 0
    private var _number_of_cbits: Int = 0
    private var result: [String:Any] = [:]
    private var _quantum_state: [Complex] = []
    private var _classical_state: Int = 0
    private var _shots: Int = 0
    private var _seed: Int = 0
    private var _threads: Int = 1
    private var _exe: String = "qasm_simulator"
    private var _cpp_backend: String = "qubit"
    private var _number_of_operations: Int = 0

    init(_ job: [String:Any]) throws {
        if let config = job["config"] as? [String:Any] {
            self.config = config
        }
        var qasm: [String:Any] = [:]
        if let compiled_circuit = job["compiled_circuit"] as? String {
            if let data = compiled_circuit.data(using: .utf8) {
                let jsonAny = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let json = jsonAny as? [String:Any] {
                    qasm = json
                }
            }
        }
        self.circuit = ["qasm" : qasm, "config": self.config]

        self.result["data"] = [:]

        if let shots = job["shots"] as? Int {
            self._shots = shots
        }
        if let seed = job["seed"] as? Int {
            self._seed = seed
        }
        // Number of threads for simulator
        if let threads = self.config["threads"] as? Int {
            self._threads = threads
        }
        // Location of simulator exe
        if let exe = self.config["exe"] as? String {
            self._exe = exe
        }
        // C++ simulator backend
        if let cpp_backend = self.config["simulator"] as? String {
            self._cpp_backend = cpp_backend
        }
        if let qasm = self.circuit["qasm"] as? [String:Any] {
            if let operations = qasm["operations"]  as? [[String:Any]] {
                self._number_of_operations = operations.count
            }
        }
    }

    func run() throws -> [String:Any] {
        preconditionFailure("CPPSimulator run not implemented")
    }
}
