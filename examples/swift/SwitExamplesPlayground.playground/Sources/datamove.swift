// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation
import qiskit

/**
 Simple test of the mapper on an example that swaps a "1" state.
 */
public final class DataMove {

    private static let backend: String = "ibmqx_qasm_simulator"
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
    private static let coupling_map = [0: [1, 8], 1: [2, 9], 2: [3, 10], 3: [4, 11], 4: [5, 12],
        5: [6, 13], 6: [7, 14], 7: [15], 8: [9], 9: [10], 10: [11],
        11: [12], 12: [13], 13: [14], 14: [15]]

    private init() {
    }

    //##############################################################
    // Make a quantum program using some swap gates.
    //##############################################################
    /**
    Swap gate.
    */
    private class func swap(_ qc: QuantumCircuit,
                            _ q0: QuantumRegisterTuple,
                            _ q1:QuantumRegisterTuple) throws {
        try qc.cx(q0, q1)
        try qc.cx(q1, q0)
        try qc.cx(q0, q1)
    }

    public class func dataMove(_ apiToken: String, _ responseHandler: ((Void) -> Void)? = nil) {
        do {
            print()
            print("#################################################################")
            print("DataMove:")
            let qConfig = try Qconfig(APItoken: apiToken)
            let qp = try QuantumProgram(specs: QPS_SPECS)
            guard let qc = qp.get_circuit("swapping") else { return }
            guard let q = qp.get_quantum_registers("q") else { return }
            guard let r = qp.get_quantum_registers("r") else { return }
            guard let ans = qp.get_classical_registers("ans") else { return }

            // Set the first bit of q
            try qc.x(q[0])

            // Swap the set bit
            try DataMove.swap(qc, q[0], q[n-1])
            try DataMove.swap(qc, q[n-1], r[n-1])
            try DataMove.swap(qc, r[n-1], q[1])
            try DataMove.swap(qc, q[1], r[1])

            // Insert a barrier before measurement
            try qc.barrier()
            // Measure all of the qubits in the standard basis
            for j in 0..<n {
                try qc.measure(q[j], ans[j])
                try qc.measure(r[j], ans[j+n])
            }
            print(qc.qasm())

            //##############################################################
            // Set up the API and execute the program.
            //##############################################################
            try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

            print("First version: not compiled")
            qp.execute(["swapping"], backend: backend,shots: 1024, coupling_map: nil) { (error) in
                do {
                    if error != nil {
                        print(error!.description)
                        responseHandler?()
                        return
                    }
                    print(try qp.get_counts("swapping"))

                    print("Second version: compiled to coupling graph")
                    qp.execute(["swapping"], backend: backend,shots: 1024, coupling_map: coupling_map) { (error) in
                        do {
                            if error != nil {
                                print(error!.description)
                                responseHandler?()
                                return
                            }
                            print(try qp.get_counts("swapping"))

                            print("Both versions should give the same distribution")
                        } catch {
                            print(error.localizedDescription)
                        }
                        responseHandler?()
                    }
                } catch {
                    print(error.localizedDescription)
                    responseHandler?()
                }
            }
        } catch {
            print(error.localizedDescription)
            responseHandler?()
        }
    }
}
