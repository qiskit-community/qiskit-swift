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
 GHZ state example illustrating mapping onto the device
 */
public final class GHZ {

    private static let backend: String = "ibmqx2"
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

    public class func ghz(_ apiToken: String, _ responseHandler: (() -> Void)? = nil) {
        do {
            print()
            print("#################################################################")
            print("GHZ:")
            let qConfig = try Qconfig()
            let qp = try QuantumProgram(specs: QPS_SPECS)
            let qc = try qp.get_circuit("ghz")
            let q = try qp.get_quantum_register("q")
            let c = try qp.get_classical_register("c")

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
            try qp.set_api(token: apiToken, url: qConfig.url.absoluteString)

            print("First version: not compiled")
            print("no mapping, simulator")
            qp.execute(["ghz"], backend: "ibmqx_qasm_simulator", coupling_map: nil,shots: 1024) { (result) in
                do {
                    if result.is_error() {
                        print(result.get_error())
                        responseHandler?()
                        return
                    }
                    print(result)
                    print(try result.get_counts("ghz"))

                    print("Second version: map to qx2 coupling graph and simulate")
                    print("map to \(backend), simulator")
                    qp.execute(["ghz"], backend: "ibmqx_qasm_simulator", coupling_map: coupling_map,shots: 1024) { (result) in
                        do {
                            if result.is_error() {
                                print(result.get_error())
                                responseHandler?()
                                return
                            }
                            print(result)
                            print(try result.get_counts("ghz"))

                            print("Third version: map to qx2 coupling graph and simulate locally")
                            print("map to \(backend), local qasm simulator")
                            qp.execute(["ghz"], backend: "local_qasm_simulator",coupling_map: coupling_map,shots: 1024) { (result) in
                                do {
                                    if result.is_error() {
                                        print(result.get_error())
                                        responseHandler?()
                                        return
                                    }
                                    print(result)
                                    print(try result.get_counts("ghz"))

                                    print("Fourth version: map to qx2 coupling graph and run on qx2")
                                    print("map to \(backend), backend")
                                    qp.execute(["ghz"], backend: backend,timeout:120, coupling_map: coupling_map,shots: 1024) { (result) in
                                        do {
                                            if result.is_error() {
                                                print(result.get_error())
                                                responseHandler?()
                                                return
                                            }
                                            print(result)
                                            print(try result.get_counts("ghz"))
                                            print("ghz end")
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
