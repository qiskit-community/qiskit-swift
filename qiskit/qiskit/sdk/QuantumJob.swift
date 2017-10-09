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
 Creates a quantum circuit job
 */
final class QuantumJob {

    private var names: [String]
    private let timeout: Int
    private(set) var qobj: [String:Any] = [:]
    private(set) var backend: String = ""
    private var resources: [String:Any] = [:]
    private let seed: Int?
    private var result: Result? = nil

    init(_ qobj: [String:Any],
         _ timeout: Int = 60,
         _ seed: Int? = nil,
         _ names: [String]? = nil) {

        if let n = names {
            self.names = n
        }
        else {
            self.names = [String.randomAlphanumeric(length: 10)]
        }
        self.timeout = timeout
        self.qobj = qobj
        if let config = self.qobj["config"] as? [String:Any] {
            if let backend = config["backend"] as? String {
                self.backend = backend
            }
            if let max_credits = config["max_credits"] {
                self.resources = ["max_credits": max_credits]
            }
        }
        self.seed = seed
    }

    init(_ circuits: [DAGCircuit],
         _ backend: String = "local_qasm_simulator",
         _ circuit_config: [[String:Any]]? = nil,
         _ timeout: Int = 60,
         _ seed: Int? = nil,
         _ shots: Int = 1024,
         _ names: [String]? = nil,
         _ do_compile: Bool = false) throws {

        if let n = names {
            self.names = n
        }
        else {
            self.names = []
            for _ in 0..<circuits.count {
                self.names.append(String.randomAlphanumeric(length: 10))
            }
        }
        self.timeout = timeout
        self.seed = seed
        self.qobj = try self._create_qobj(circuits, circuit_config, backend, self.seed, shots, do_compile)
        if let config = self.qobj["config"] as? [String:Any] {
            if let backend = config["backend"] as? String {
                self.backend = backend
            }
            if let max_credits = config["max_credits"] {
                self.resources = ["max_credits": max_credits]
            }
        }
    }

    private func _create_qobj(_ circuits: [DAGCircuit],
                              _ circuit_conf: [[String:Any]]?,
                              _ backend: String,
                              _ seed: Int?,
                              _ shots: Int,
                              _ do_compile: Bool) throws -> [String:Any] {
        // local and remote backends currently need different
        // compilied circuit formats
        var formatted_circuits: [Any] = []
        if do_compile {
            for _ in circuits {
                formatted_circuits.append(NSNull())
            }
        }
        else {
            if BackendUtils.local_backends().contains(backend) {
                for circuit in circuits {
                    formatted_circuits.append(try OpenQuantumCompiler.dag2json(circuit))
                }
            }
            else {
                for circuit in circuits {
                    formatted_circuits.append(try circuit.qasm(qeflag: true))
                }
            }
        }
        // create circuit component of qobj
        var circuit_config: [[String:Any]] = []
        if let c = circuit_conf {
            circuit_config = c
        }
        else {
            let config: [String:Any] = ["coupling_map": NSNull(),
                                        "basis_gates": "u1,u2,u3,cx,id",
                                        "layout": NSNull(),
                                        "seed": seed != nil ? seed! : NSNull()]
            circuit_config = [[String:Any]](repeating: config, count: circuits.count)
        }
        var circuit_records: [[String:Any]] = []
        for ((circuit, fcircuit), (name, config)) in zip(zip(circuits,formatted_circuits),zip(self.names,circuit_config)) {
            let record: [String:Any] = [
                "name": name,
                "compiled_circuit": do_compile ? NSNull() : fcircuit,
                "compiled_circuit_qasm": do_compile ? NSNull() : fcircuit,
                "circuit": circuit,
                "config": config
            ]
            circuit_records.append(record)
        }
        return ["id": String.randomAlphanumeric(length: 10),
                "config": [
                    "max_credits": resources["max_credits"],
                    "shots": shots,
                    "backend": backend
                ],
                "circuits": circuit_records]
    }
}
