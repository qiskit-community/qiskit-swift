//
//  ghz.swift
//  TestSwiftSDK
//
//  Created by Manoel Marques on 6/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

/**
 GHZ state example illustrating mapping onto the device
 */
public final class GHZ {

    private static let device: String = "ibmqx2"
    private static let QPS_SPECS: [String: Any] = [
        "name": "ghz",
        "circuits": [[
            "name": "ghz",
            "quantum_registers": [
                ["name": "q", "size": 5]
            ],
            "classical_registers": [
                ["name": "c", "size": 5]
            ]]]
    ]

    //#############################################################
    // Set the device name and coupling map.
    //#############################################################
    private static let coupling_map = [0: [1, 2],
        1: [2],
        2: [],
        3: [2, 4],
        4: [2]]

    private init() {
    }

    //##############################################################
    // Make a quantum program for the GHZ state.
    //##############################################################

    public class func ghz(qConfig: Qconfig) throws {
        let qp = try QuantumProgram(specs: QPS_SPECS)
        guard let qc = qp.get_circuit("ghz") else { return }
        guard let q = qp.get_quantum_registers("q") else { return }
        guard let c = qp.get_classical_registers("c") else { return }

        // Create a GHZ state
        try qc.h(q[0])
        for i in 0..<4 {
            try qc.cx(q[i], q[i+1])
        }
        // Insert a barrier before measurement
        try qc.barrier()
        // Measure all of the qubits in the standard basis
        for i in 0..<5 {
            try qc.measure(q[i], c[i])
        }

        //##############################################################
        // Set up the API and execute the program.
        //##############################################################
        try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

        // First version: not compiled
        print("no compilation, simulator")
        qp.execute(["ghz"], backend: "ibmqx_qasm_simulator",shots: 1024, coupling_map: nil) { (error) in
            do {
                if error != nil {
                    print(error!.description)
                    return
                }
                print(try qp.get_compiled_qasm("ghz"))
                print(try qp.get_counts("ghz"))

                // Second version: compiled to qc5qv2 coupling graph
                print("compilation to \(device), simulator")
                qp.execute(["ghz"], backend: "ibmqx_qasm_simulator",shots: 1024, coupling_map: coupling_map) { (error) in
                    do {
                        if error != nil {
                            print(error!.description)
                            return
                        }
                        print(try qp.get_compiled_qasm("ghz"))
                        print(try qp.get_counts("ghz"))

                        // Third version: compiled to qc5qv2 coupling graph
                      /*  print("compilation to \(device), local qasm simulator")
                        qp.execute(["ghz"], backend: "ibmqx_qasm_simulator",shots: 1024, coupling_map: coupling_map) { (error) in
                            do {
                                if error != nil {
                                    print(error!.description)
                                    return
                                }
                                print(try qp.get_counts("ghz"))

                                // Fourth version: compiled to qc5qv2 coupling graph and run on qx5q
                                print("compilation to \(device), device")
                                qp.execute(["ghz"], backend: device,shots: 1024, timeout:120, coupling_map: coupling_map) { (error) in
                                    do {
                                        if error != nil {
                                            print(error!.description)
                                            return
                                        }
                                        print(try qp.get_counts("ghz"))
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }*/
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
