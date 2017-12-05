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

    // enter your token in your test schema environment variable "QUANTUM_TOKEN"
    static private var APItoken: String = "None"
    static private let TESTURL = "https://quantumexperience.ng.bluemix.net/api/"

    static private var config: Qconfig? = nil

    override class func setUp() {
        let environment = ProcessInfo.processInfo.environment
        if let token = environment["QUANTUM_TOKEN"] {
            UnrollerTests.APItoken = token
        }
        do {
            UnrollerTests.config = try Qconfig(url: TESTURL)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRippleAddUnroller() {
        do {
            try self.rippleAdd(UnrollerTests.config!)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    private func rippleAdd(_ qConfig: Qconfig) throws {
        let qp = try QuantumProgram(specs: UnrollerTests.QPS_SPECS)
        var qc = try qp.get_circuit("rippleadd")
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
        try qc += adder_subcircuit
        // Measure the output register in the computational basis
        for j in 0..<UnrollerTests.n {
            try qc.measure(b[j], ans[j])
        }
        try qc.measure(cout[0], ans[UnrollerTests.n])

        //###############################################################
        //# Set up the API and execute the program.
        //###############################################################
        try qp.set_api(token: UnrollerTests.APItoken, url: qConfig.url.absoluteString)

        let QASM_source = try qp.get_qasm("rippleadd")
        SDKLogger.logInfo(QASM_source)

        let qobj = try qp.compile(["rippleadd"], backend: UnrollerTests.backend, coupling_map: UnrollerTests.coupling_map, shots: 1024)
        qp.get_execution_list(qobj)
       /* let asyncExpectation = self.expectation(description: "runJob")
        qp.run_async(qobj) { (result) in
            do {
                if let error = result.get_error() {
                    XCTFail("Failure in runJob: \(error)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(try result.get_ran_qasm("rippleadd"))
                SDKLogger.logInfo(try result.get_counts("rippleadd"))
                // Both versions should give the same distribution
                asyncExpectation.fulfill()
            } catch {
                XCTFail("Failure in runJob: \(error)")
                asyncExpectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in runJob")
        })*/
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
