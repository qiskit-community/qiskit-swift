//
//  QasmCppSimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

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
