//
//  LocalSimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class LocalSimulator: Simulator {

    static let local_configuration = [
            [
                "name": "local_qasm_simulator",
                "url": "https://github.com/IBM/qiskit-sdk-py",
                "simulator": true,
                "description": "A python simulator for qasm files",
                "nQubits": 10,
                "couplingMap": "all-to-all",
                "gateset": "SU2+CNOT"
            ],
            [
                "name": "local_qasm_cpp_simulator",
                "url": "https://github.com/IBM/qiskit-sdk-py",
                "simulator": true,
                "description": "A python simulator for qasm files",
                "nQubits": 10,
                "couplingMap": "all-to-all",
                "gateset": "SU2+CNOT"
            ],
            [
                "name": "local_unitary_simulator",
                "url": "https://github.com/IBM/qiskit-sdk-py",
                "simulator": true,
                "description": "A cpp simulator for qasm files",
                "nQubits": 10,
                "couplingMap": "all-to-all",
                "gateset": "SU2+CNOT"
            ]
    ]

    private let backend: String
    private let job: [String:Any]
    private var _result: [String:Any] = [:]

    var result: [String:Any] {
        return self._result
    }

    init(_ backend: String, _ job: [String:Any]) {
        self.backend = backend
        self.job = job
    }

    func run() throws -> [String:Any] {
        guard let circuit = self.job["compiled_circuit"] as? String else {
            throw QISKitException.missingBackend(backend: self.backend)
        }
        var sim: Simulator
        if self.backend == "local_qasm_simulator" {
            guard let shots = self.job["shots"] as? Int else {
                throw QISKitException.missingBackend(backend: self.backend)
            }
            if let seed = self.job["seed"] as? Double {
                sim = QasmSimulator(circuit,shots,seed)
            }
            else {
                sim = QasmSimulator(circuit,shots)
            }
        }
        else if self.backend == "local_unitary_simulator" {
            sim = UnitarySimulator(circuit)
        }
        else if self.backend == "local_qasm_cpp_simulator" {
            guard let shots = self.job["shots"] as? Int else {
                throw QISKitException.missingBackend(backend: self.backend)
            }
            sim = QasmCppSimulator(circuit,shots,self.job["seed"] as? Double)
        }
        else {
            throw QISKitException.missingBackend(backend: self.backend)
        }
        let simOutput = try sim.run()
        self._result["result"] = []
        if let data = simOutput["data"] {
            self._result["result"] = ["data" : data]
        }
        if let status = simOutput["status"] {
            self._result["status"] = status
        }
        return self._result
    }
}
