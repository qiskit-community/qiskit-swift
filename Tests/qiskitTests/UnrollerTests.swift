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

import XCTest
@testable import qiskit

class UnrollerTests: XCTestCase {

    static let allTests = [
        ("testRippleAddUnroller",testRippleAddUnroller)
    ]

    private static let backend: String = "simulator"
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
                ["name": "ans", "size": n + 1],
            ]]]
    ]

    private var QE_TOKEN: String? = nil
    private var QE_URL = Qconfig.BASEURL

    override func setUp() {
        super.setUp()
        let environment = ProcessInfo.processInfo.environment
        if let token = environment["QE_TOKEN"] {
            self.QE_TOKEN = token
        }
        if let url = environment["QE_URL"] {
            self.QE_URL = url
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRippleAddUnroller() {
        do {
            try self.rippleAdd()
        } catch let error {
            XCTFail("testRippleAddUnroller fail: \(error)")
        }
    }

    private func rippleAdd() throws {
        let qp = try QuantumProgram(specs: UnrollerTests.QPS_SPECS)
        let qc = try qp.get_circuit("rippleadd")
        let a = try qp.get_quantum_register("a")
        let b = try qp.get_quantum_register("b")
        let cin = try qp.get_quantum_register("cin")
        let cout = try qp.get_quantum_register("cout")
        let ans = try qp.get_classical_register("ans")

        // Build a temporary subcircuit that adds a to b,
        // storing the result in b
        let adder_subcircuit = try QuantumCircuit([cin, a, b, cout])
        try UnrollerTests.majority(adder_subcircuit, cin[0], b[0], a[0])
        for j in 0..<(UnrollerTests.n-1) {
            try UnrollerTests.majority(adder_subcircuit, a[j], b[j + 1], a[j + 1])
        }
        try adder_subcircuit.cx(a[UnrollerTests.n - 1], cout[0])
        for j in (0..<(UnrollerTests.n-1)).reversed() {
            try UnrollerTests.unmajority(adder_subcircuit, a[j], b[j + 1], a[j + 1])
        }
        try UnrollerTests.unmajority(adder_subcircuit, cin[0], b[0], a[0])

        // Set the inputs to the adder
        try qc.x(a[0])  // Set input a = 0...0001
        try qc.x(b)   // Set input b = 1...1111
        // Apply the adder
        try qc.extend(adder_subcircuit)
        // Measure the output register in the computational basis
        for j in 0..<UnrollerTests.n {
            try qc.measure(b[j], ans[j])
        }
        try qc.measure(cout[0], ans[UnrollerTests.n])

        let QASM_source = try qp.get_qasm("rippleadd")
        SDKLogger.logInfo(QASM_source)

        guard let token = self.QE_TOKEN else {
            return
        }
        //###############################################################
        //# Set up the API and execute the program.
        //###############################################################
        try qp.set_api(token:token, url:QE_URL)

        let qobj = try qp.compile(["rippleadd"], backend: UnrollerTests.backend, coupling_map: UnrollerTests.coupling_map, shots: 1024)
        qp.get_execution_list(qobj)
        let asyncExpectation = self.expectation(description: "rippleAdd")
        qp.run_async(qobj) { (result) in
            do {
                if let error = result.get_error() {
                    XCTFail("Failure in rippleAdd: \(error)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(try result.get_ran_qasm("rippleadd"))
                SDKLogger.logInfo(try result.get_counts("rippleadd"))
                // Both versions should give the same distribution
                asyncExpectation.fulfill()
            } catch {
                XCTFail("Failure in rippleAdd: \(error)")
                asyncExpectation.fulfill()
            }
        }
        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in rippleAdd")
        })
    }

    private class func majority(_ p: QuantumCircuit,
                                _ a: QuantumRegisterTuple,
                                _ b:QuantumRegisterTuple,
                                _ c:QuantumRegisterTuple) throws {
        try p.cx(c, b)
        try p.cx(c, a)
        try p.ccx(a, b, c)
    }

    private class func unmajority(_ p: QuantumCircuit,
                                  _ a: QuantumRegisterTuple,
                                  _ b:QuantumRegisterTuple,
                                  _ c:QuantumRegisterTuple) throws {
        try p.ccx(a, b, c)
        try p.cx(c, a)
        try p.cx(a, b)
    }
}
