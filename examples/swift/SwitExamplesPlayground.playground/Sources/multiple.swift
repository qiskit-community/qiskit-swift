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
public final class Multiple {

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
    private static let coupling_map = [0: [1, 2],
        1: [2],
        2: [],
        3: [2, 4],
        4: [2]]

    private init() {
    }

    //##############################################################
    // Make a quantum program for the GHZ and Bell states.
    //##############################################################
   
    public class func multiple(qConfig: Qconfig) throws {
        let qp = try QuantumProgram(specs: QPS_SPECS)
        guard let ghz = qp.get_circuit("ghz") else { return }
        guard let bell = qp.get_circuit("bell") else { return }
        guard let q = qp.get_quantum_registers("q") else { return }
        guard let c = qp.get_classical_registers("c") else { return }

        // Create a GHZ state
        try ghz.h(q[0])
        for i in 0..<4 {
            try ghz.cx(q[i], q[i+1])
        }
        // Insert a barrier before measurement
        try ghz.barrier()
        // Measure all of the qubits in the standard basis
        for i in 0..<5 {
            try ghz.measure(q[i], c[i])
        }

        // Create a Bell state
        try bell.h(q[0])
        try bell.cx(q[0], q[1])
        try bell.barrier()
        try bell.measure(q[0], c[0])
        try bell.measure(q[1], c[1])

        print(ghz.qasm())
        print(bell.qasm())

        //##############################################################
        // Set up the API and execute the program.
        //##############################################################
        try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

        try qp.compile(["bell"], device:"simulator" /*"local_qasm_simulator"*/, shots:1024)
        try qp.compile(["ghz"], device:"simulator", shots:1024,coupling_map:coupling_map)

        qp.run() { (error) in
            do {
                if error != nil {
                    print(error!.description)
                    return
                }
                // print(try qp.get_counts("bell")) // returns error, don't do this
                print(try qp.get_counts("bell", device:"local_qasm_simulator"))
                print(try qp.get_counts("ghz"))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
