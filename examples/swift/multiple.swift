//
//  multiple.swift
//  TestSwiftSDK
//
//  Created by Manoel Marques on 6/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

/**
 Illustrate compiling several circuits to different backends.
 */
final class Multiple {

    private static let device: String = "ibmqx2"

    private static let QPS_SPECS: [String: Any] = [
        "name": "programs",
        "circuits": [
            ["name": "ghz",
            "quantum_registers": [
                ["name": "q","size": 5]
            ],
            "classical_registers": [
                ["name": "c","size": 5]
            ]],
            ["name": "bell",
            "quantum_registers": [
                ["name": "q","size": 5]
            ],
            "classical_registers": [
                ["name": "c","size": 5]
            ]]
        ]
    ]

    //##############################################################
    // Set the device name and coupling map.
    //##############################################################
    coupling_map = {0: [1, 2],
        1: [2],
        2: [],
        3: [2, 4],
        4: [2]}

    //##############################################################
    // Make a quantum program for the GHZ and Bell states.
    //##############################################################
    QPS_SPECS = {
        "name": "programs",
        "circuits": [{
        "name": "ghz",
        "quantum_registers": [{
        "name": "q",
        "size": 5
        }],
        "classical_registers": [
        {"name": "c",
        "size": 5}
        ]},{
        "name": "bell",
        "quantum_registers": [{
        "name": "q",
        "size": 5
        }],
        "classical_registers": [
        {"name": "c",
        "size": 5
        }]}
        ]
    }

    qp = QuantumProgram(specs=QPS_SPECS)
    ghz = qp.get_circuit("ghz")
    bell = qp.get_circuit("bell")
    q = qp.get_quantum_registers("q")
    c = qp.get_classical_registers("c")

    // Create a GHZ state
    ghz.h(q[0])
    for i in range(4):
    ghz.cx(q[i], q[i+1])
    // Insert a barrier before measurement
    ghz.barrier()
    // Measure all of the qubits in the standard basis
    for i in range(5):
    ghz.measure(q[i], c[i])

    // Create a Bell state
    bell.h(q[0])
    bell.cx(q[0], q[1])
    bell.barrier()
    bell.measure(q[0], c[0])
    bell.measure(q[1], c[1])

    print(ghz.qasm())
    print(bell.qasm())

    //##############################################################
    // Set up the API and execute the program.
    //##############################################################
    result = qp.set_api(Qconfig.APItoken, Qconfig.config["url"])
    if not result:
    print("Error setting API")
    sys.exit(1)

    qp.compile(["bell"], device='local_qasm_simulator', shots=1024)
    qp.compile(["ghz"], device='simulator', shots=1024,
    coupling_map=coupling_map)

    qp.run()

    // print(qp.get_counts("bell")) # returns error, don't do this
    print(qp.get_counts("bell", device="local_qasm_simulator"))
    print(qp.get_counts("ghz"))

}
