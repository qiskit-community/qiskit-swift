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

/**
 Test local qasm simulator.
 */
class LocalQasmSimulatorTest: XCTestCase {

    private var seed: Int = 0
    private var qp: QuantumProgram? = nil
    private var qobj: [String:Any] = [:]

    private static let resources: [String:Any] = ["max_credits": 3,
                                                  "wait": 5,
                                                  "timeout": 120]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "qasm", ofType: "bundle") else {
            XCTFail("Bundle qasm not found")
            return
        }
        guard let qasmBundle = Bundle(path: path) else {
            XCTFail("Bundle not found \(path)")
            return
        }
        guard let url = qasmBundle.url(forResource: "example", withExtension: "qasm") else {
            XCTFail("Bundle example path not found")
            return
        }
        do {
            self.seed = 88
            self.qp = try QuantumProgram()
            try self.qp!.load_qasm_text(qasm_string: try String(contentsOf: url, encoding: .utf8), name: "example")
            let basis_gates: [String] = []  // unroll to base gates
            let unroller = Unroller(try Qasm(data: try self.qp!.get_qasm("example")).parse(),JsonBackend(basis_gates))
            let circuit = try unroller.execute()
            let circuit_config: [String:Any] = ["coupling_map": NSNull(),
                                                "basis_gates": "u1,u2,u3,cx,id",
                                                "layout": NSNull(),
                                                "seed": self.seed]
            self.qobj = ["id": "test_sim_single_shot",
                "config": [
                    "max_credits": LocalQasmSimulatorTest.resources["max_credits"],
                    "shots": 1024,
                    "backend": "local_qasm_simulator",
                ],
                "circuits": [
                    [
                    "name": "test",
                    "compiled_circuit": circuit,
                    "compiled_circuit_qasm": NSNull(),
                    "config": circuit_config
                    ]
                ]
            ]
        } catch {
            XCTFail("\(url.lastPathComponent): \(error)")
        }

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
     Test single shot run.
     */
    func test_qasm_simulator_single_shot() {
        let shots = 1
        var config: [String:Any] = ["shots":shots]
        if let c = self.qobj["config"] as? [String:Any] {
            config = c
            config["shots"] = shots
        }
        self.qobj["config"] = config
        let q_job = QuantumJob(self.qobj,
                                seed: self.seed,
                                resources: LocalQasmSimulatorTest.resources)
        let asyncExpectation = self.expectation(description: "runSimulator")
        QasmSimulator().run(q_job) { (result) in
            XCTAssertEqual(result.get_status(), "COMPLETED")
            asyncExpectation.fulfill()
        }
        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in test_qasm_simulator_single_shot")
        })
    }

    /**
     Test data counts output for single circuit run against reference.
     */
    func test_qasm_simulator() {
        let expected: [String:Int] = ["100 100": 113, "011 011": 124, "101 101": 118, "111 111": 116, "000 000": 132, "010 010": 135, "110 110": 141, "001 001": 145]
        let q_job = QuantumJob(self.qobj,
                               seed: self.seed,
                               resources: LocalQasmSimulatorTest.resources)
        let asyncExpectation = self.expectation(description: "runSimulator")
        QasmSimulator().run(q_job) { (result) in
            do {
                let counts = try result.get_counts("test")
                XCTAssertEqual(counts, expected)
            } catch {
                XCTFail("\(error)")
            }
            asyncExpectation.fulfill()
        }
        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in test_qasm_simulator")
        })
    }
}
