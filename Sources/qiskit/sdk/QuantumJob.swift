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
public final class QuantumJob {

    public private(set) var names: [String]
    public let timeout: Int
    public let wait: Int
    public var qobj: [String:Any] {
        return self._qobj
    }
    var _qobj: [String:Any] = [:]
    public private(set) var backend: String = ""
    public private(set) var resources: [String:Any] = [:]
    public let seed: Int?
    public private(set) var result: Result? = nil

    init(_ qobj: [String:Any],
         seed: Int? = nil,
         resources: [String:Any] = ["max_credits":10, "wait":5, "timeout":120],
         names: [String]? = nil) {

        if let n = names {
            self.names = n
        }
        else {
            self.names = [String.randomAlphanumeric(length: 10)]
        }
        if let t = resources["timeout"] as? Int {
            self.timeout = t
        }
        else {
            self.timeout = 120
        }
        if let w = resources["wait"] as? Int {
            self.wait = w
        }
        else {
            self.wait = 5
        }
        self._qobj = qobj
        self.seed = seed
        if let config = self.qobj["config"] as? [String:Any] {
            if let backend = config["backend"] as? String {
                self.backend = backend
            }
        }
        self.resources = resources
    }

    init(_ circuits: [DAGCircuit],
         backend: String = "local_qasm_simulator",
         circuit_config: [[String:Any]]? = nil,
         seed: Int? = nil,
         resources: [String:Any] = ["max_credits":3, "wait":5, "timeout":120],
         shots: Int = 1024,
         names: [String]? = nil,
         do_compile: Bool = false,
         _ backendUtils: BackendUtils) throws {

        if let n = names {
            self.names = n
        }
        else {
            self.names = []
            for _ in 0..<circuits.count {
                self.names.append(String.randomAlphanumeric(length: 10))
            }
        }
        if let t = resources["timeout"] as? Int {
            self.timeout = t
        }
        else {
            self.timeout = 120
        }
        if let w = resources["wait"] as? Int {
            self.wait = w
        }
        else {
            self.wait = 5
        }
        self.seed = seed
        self._qobj = try self._create_qobj(circuits, circuit_config, backend, self.seed, shots, do_compile,backendUtils)
        if let config = self.qobj["config"] as? [String:Any] {
            if let backend = config["backend"] as? String {
                self.backend = backend
            }
        }
        self.resources = resources
    }

    private func _create_qobj(_ circuits: [DAGCircuit],
                              _ circuit_conf: [[String:Any]]?,
                              _ backend: String,
                              _ seed: Int?,
                              _ shots: Int,
                              _ do_compile: Bool,
                              _ backendUtils: BackendUtils) throws -> [String:Any] {
        // local and remote backends currently need different
        // compilied circuit formats
        var formatted_circuits: [Any] = []
        if do_compile {
            for _ in circuits {
                formatted_circuits.append(NSNull())
            }
        }
        else {
            if backendUtils.local_backends().contains(backend) {
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
