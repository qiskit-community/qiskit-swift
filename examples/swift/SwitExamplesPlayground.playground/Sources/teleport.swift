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
 Quantum teleportation example based on an OpenQASM example.
 */
public final class Teleport {

    private static let backend: String = "ibmqx_qasm_simulator"

    private static let QPS_SPECS: [String: Any] = [
            "name": "Program",
            "circuits": [[
                "name": "teleport",
                "quantum_registers": [[
                    "name": "q",
                    "size": 3
            ]],
            "classical_registers": [
                ["name": "c0",
                "size": 1],
                ["name": "c1",
                "size": 1],
                ["name": "c2",
                "size": 1],
            ]]]
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
   
    public class func teleport(qConfig: Qconfig) throws {
        let qp = try QuantumProgram(specs: QPS_SPECS)
        guard let qc = qp.get_circuit("teleport") else { return }
        guard let q = qp.get_quantum_registers("q") else { return }
        guard let c0 = qp.get_classical_registers("c0") else { return }
        guard let c1 = qp.get_classical_registers("c1") else { return }
        guard let c2 = qp.get_classical_registers("c2") else { return }

        // Prepare an initial state
        try qc.u3(0.3, 0.2, 0.1, q[0])

        // Prepare a Bell pair
        try qc.h(q[1])
        try qc.cx(q[1], q[2])

        // Barrier following state preparation
        try qc.barrier(q)

        // Measure in the Bell basis
        try qc.cx(q[0], q[1])
        try qc.h(q[0])
        try qc.measure(q[0], c0[0])
        try qc.measure(q[1], c1[0])

        // Apply a correction
        try qc.z(q[2]).c_if(c0, 1)
        try qc.x(q[2]).c_if(c1, 1)
        try qc.measure(q[2], c2[0])

        print(qc.qasm())

        //##############################################################
        // Set up the API and execute the program.
        //##############################################################
        try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

        print("Experiment does not support feedback, so we use the simulator")

        print("First version: not compiled")
        qp.execute(["teleport"], backend: backend,shots: 1024, coupling_map: nil) { (error) in
            do {
                if error != nil {
                    print(error!.description)
                    return
                }
                print(try qp.get_counts("teleport"))

                print("Second version: compiled to ibmqx2 coupling graph")
                try qp.compile(["teleport"], backend: backend, shots: 1024, coupling_map: coupling_map)
                qp.run() { (error) in
                    do {
                        if error != nil {
                            print(error!.description)
                            return
                        }
                        print(try qp.get_counts("teleport"))
                        print("Both versions should give the same distribution")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
