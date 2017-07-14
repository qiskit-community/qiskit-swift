//
//  qft.swift
//  TestSwiftSDK
//
//  Created by Manoel Marques on 6/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

/**
 Quantum Fourier Transform examples.
 */
public final class QFT {

    private static let device: String = "ibmqx2"

    private static let QPS_SPECS: [String: Any] = [
        "name": "ghz",
        "circuits": [
            ["name": "qft3",
            "quantum_registers": [
                ["name": "q","size": 5]
                ],
            "classical_registers": [
                ["name": "c","size": 5]
                ]],
             ["name": "qft4",
                "quantum_registers": [
                    ["name": "q","size": 5
                ]],
                "classical_registers": [
                    ["name": "c","size": 5]
                ]],
             ["name": "qft5",
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
    // Make a quantum program for the GHZ state.
    //##############################################################

    /**
     n-qubit input state for QFT that produces output 1.
     */
    private class func input_state(_ circ: QuantumCircuit, _ q: QuantumRegister, _ n: Int) throws {
        for j in 0..<n {
            try circ.h(q[j])
            try circ.u1(Double.pi/NSDecimalNumber(decimal:pow(2,j)).doubleValue, q[j]).inverse()
        }
    }
    /**
     n-qubit QFT on q in circ
     */
    private class func qft(_ circ: QuantumCircuit, _ q: QuantumRegister, _ n: Int) throws {
        for j in 0..<n {
            for k in 0..<j {
                try circ.cu1(Double.pi/NSDecimalNumber(decimal:pow(2,j-k)).doubleValue, q[j], q[k])
            }
            try circ.h(q[j])
        }
    }

    public class func qft(qConfig: Qconfig) throws {
        let qp = try QuantumProgram(specs: QPS_SPECS)
        guard let q = qp.get_quantum_registers("q") else { return }
        guard let c = qp.get_classical_registers("c") else { return }

        guard let qft3 = qp.get_circuit("qft3") else { return }
        guard let qft4 = qp.get_circuit("qft4") else { return }
        guard let qft5 = qp.get_circuit("qft5") else { return }

        try input_state(qft3, q, 3)
        try qft3.barrier()
        try qft(qft3, q, 3)
        try qft3.barrier()
        for j in 0..<3 {
            try qft3.measure(q[j], c[j])
        }

        try input_state(qft4, q, 4)
        try qft4.barrier()
        try qft(qft4, q, 4)
        try qft4.barrier()
        for j in 0..<4 {
            try qft4.measure(q[j], c[j])
        }

        try input_state(qft5, q, 5)
        try qft5.barrier()
        try qft(qft5, q, 5)
        try qft5.barrier()
        for j in 0..<5 {
            try qft5.measure(q[j], c[j])
        }

        print(qft3.qasm())
        print(qft4.qasm())
        print(qft5.qasm())


        //##############################################################
        // Set up the API and execute the program.
        //##############################################################
        try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

        qp.execute(["qft3", "qft4", "qft5"], backend:"ibmqx_qasm_simulator",shots: 1024, coupling_map: coupling_map) { (error) in
            do {
                if error != nil {
                    print(error!.description)
                    return
                }
                print(try qp.get_compiled_qasm("qft3"))
                print(try qp.get_compiled_qasm("qft4"))
                print(try qp.get_compiled_qasm("qft5"))
                print(try qp.get_counts("qft3"))
                print(try qp.get_counts("qft4"))
                print(try qp.get_counts("qft5"))

                qp.execute(["qft3"], backend:device,shots: 1024, timeout:120, coupling_map: coupling_map) { (error) in
                    do {
                        if error != nil {
                            print(error!.description)
                            return
                        }
                        print(try qp.get_compiled_qasm("qft3"))
                        print(try qp.get_counts("qft3"))
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
