//
//  DataMove.swift
//  TestSwiftSDK
//
//  Created by Manoel Marques on 6/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

/**
 Simple test of the mapper on an example that swaps a "1" state.
 */
final class DataMove {

    private static let device: String = "simulator"
    private static let n: Int = 3  // make this at least 3

    private static let QPS_SPECS: [String: Any] = [
        "name": "Program",
        "circuits": [[
            "name": "swapping",
            "quantum_registers": [
                ["name": "q", "size": n],
                ["name": "r", "size": n]
            ],
            "classical_registers": [
                ["name": "ans", "size": 2*n]
            ]]]
    ]

    //##############################################################
    // Set the device name and coupling map.
    //##############################################################
    coupling_map = {0: [1, 8], 1: [2, 9], 2: [3, 10], 3: [4, 11], 4: [5, 12],
        5: [6, 13], 6: [7, 14], 7: [15], 8: [9], 9: [10], 10: [11],
        11: [12], 12: [13], 13: [14], 14: [15]}

    //##############################################################
    // Make a quantum program using some swap gates.
    //##############################################################
    def swap(qc, q0, q1):
    """Swap gate."""
    qc.cx(q0, q1)
    qc.cx(q1, q0)
    qc.cx(q0, q1)

    qp = QuantumProgram(specs=QPS_SPECS)
    qc = qp.get_circuit("swapping")
    q = qp.get_quantum_registers("q")
    r = qp.get_quantum_registers("r")
    ans = qp.get_classical_registers("ans")

    // Set the first bit of q
    qc.x(q[0])

    // Swap the set bit
    swap(qc, q[0], q[n-1])
    swap(qc, q[n-1], r[n-1])
    swap(qc, r[n-1], q[1])
    swap(qc, q[1], r[1])

    // Insert a barrier before measurement
    qc.barrier()
    // Measure all of the qubits in the standard basis
    for j in range(n):
    qc.measure(q[j], ans[j])
    qc.measure(r[j], ans[j+n])

    //##############################################################
    // Set up the API and execute the program.
    //##############################################################
    result = qp.set_api(Qconfig.APItoken, Qconfig.config["url"])
    if not result:
    print("Error setting API")
    sys.exit(1)

    // First version: not compiled
    result = qp.execute(["swapping"], device=device, coupling_map=None, shots=1024)
    print(qp.get_compiled_qasm("swapping"))
    print(qp.get_counts("swapping"))

    // Second version: compiled to coupling graph
    result = qp.execute(["swapping"], device=device, coupling_map=coupling_map, shots=1024)
    print(qp.get_compiled_qasm("swapping"))
    print(qp.get_counts("swapping"))

    // Both versions should give the same distribution
}
