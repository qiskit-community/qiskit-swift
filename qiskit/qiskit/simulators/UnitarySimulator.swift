//
//  UnitarySimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

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
    
    init(_ job: [String:Any]) {

    }

    func run() throws -> [String:Any] {
        return [:]
    }
}
