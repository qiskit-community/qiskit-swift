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

    init(_ job: [String:Any], _ threads: Int = 1,_ config: [String:Any]? = nil, _ exe: String = "qasm_simulator") {

    }
    
    func run() throws -> [String:Any] {
        return [:]
    }
}
