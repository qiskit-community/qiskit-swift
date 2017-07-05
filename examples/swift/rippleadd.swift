//
//  RippleAdd.swift
//  TestSwiftSDK
//
//  Created by Manoel Marques on 6/13/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

final class RippleAdd {

    private static let device: String = "simulator"
    private static let coupling_map = [0: [1, 8], 1: [2, 9], 2: [3, 10], 3: [4, 11], 4: [5, 12],
                                        5: [6, 13], 6: [7, 14], 7: [15], 8: [9], 9: [10], 10: [11],
                                        11: [12], 12: [13], 13: [14], 14: [15]
                                      ]

    private static let n: Int = 2

    private static let QPS_SPECS: [String: Any] = [
                        "name": "Program",
                        "circuits": [[
                            "name": "rippleadd",
                            "quantum_registers": [
                                ["name": "a", "size": n],
                                ["name": "b", "size": n],
                                ["name": "cin", "size": 1],
                                ["name": "cout", "size": 1]
                            ],
                            "classical_registers": [
                                ["name": "ans", "size": n + 1]
                            ]]]
                        ]

    public class func rippleAdd(qConfig: Qconfig) throws {
        let qp = try QuantumProgram(specs: QPS_SPECS)
        guard var qc = qp.get_circuit("rippleadd") else {
            return
        }
        guard let a = qp.get_quantum_registers("a") else {
            return
        }
        guard let b = qp.get_quantum_registers("b") else {
            return
        }
        guard let cin = qp.get_quantum_registers("cin") else {
            return
        }
        guard let cout = qp.get_quantum_registers("cout") else {
            return
        }
        guard let ans = qp.get_classical_registers("ans") else {
            return
        }

        // Build a temporary subcircuit that adds a to b,
        // storing the result in b
        let adder_subcircuit = try QuantumCircuit([cin, a, b, cout])
        try RippleAdd.majority(adder_subcircuit, cin[0], b[0], a[0])
        for j in 0..<(n-1) {
            try RippleAdd.majority(adder_subcircuit, a[j], b[j + 1], a[j + 1])
        }
        _ = try adder_subcircuit.cx(a[n - 1], cout[0])
        for j in (0..<(n-1)).reversed() {
            try RippleAdd.unmajority(adder_subcircuit, a[j], b[j + 1], a[j + 1])
        }
        try RippleAdd.unmajority(adder_subcircuit, cin[0], b[0], a[0])

        // Set the inputs to the adder
        _ = try qc.x(a[0])  // Set input a = 0...0001
        _ = try qc.x(b)   // Set input b = 1...1111
        // Apply the adder
        try qc += adder_subcircuit
        // Measure the output register in the computational basis
        for j in 0..<n {
            _ = try qc.measure(b[j], ans[j])
        }
        _ = try qc.measure(cout[0], ans[n])

        //###############################################################
        //# Set up the API and execute the program.
        //###############################################################
        try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

        // First version: not compiled
        qp.execute(["rippleadd"], device: device,shots: 1024, coupling_map: nil) { (result,error) in
            do {
                if error != nil {
                    print(error!.description)
                    return
                }
                print(result!)
                print(try qp.get_counts("rippleadd"))
                // Second version: compiled to 2x8 array coupling graph
                try qp.compile(["rippleadd"], device: device, shots: 1024, coupling_map: coupling_map)
                // qp.print_execution_list(verbose=True)
                qp.run() { (result,error) in
                    do {
                        if error != nil {
                            print(error!.description)
                            return
                        }
                        print(result!)
                        print(try qp.get_compiled_qasm("rippleadd"))
                        print(try qp.get_counts("rippleadd"))
                        // Both versions should give the same distribution
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private class func majority(_ p: QuantumCircuit,
                                _ a: QuantumRegisterTuple,
                                _ b:QuantumRegisterTuple,
                                _ c:QuantumRegisterTuple) throws {
        _ = try p.cx(c, b)
        _ = try p.cx(c, a)
        _ = try p.ccx(a, b, c)
    }

    private class func unmajority(_ p: QuantumCircuit,
                                  _ a: QuantumRegisterTuple,
                                  _ b:QuantumRegisterTuple,
                                  _ c:QuantumRegisterTuple) throws {
        _ = try p.ccx(a, b, c)
        _ = try p.cx(c, a)
        _ = try p.cx(a, b)
    }
}
