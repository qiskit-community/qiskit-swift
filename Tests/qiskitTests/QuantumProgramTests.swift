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
 QISKIT QuatumProgram Object Tests.
 */
class QuantumProgramTests: XCTestCase {

    #if os(Linux)
    static let allTests = [
        ("test_fail_create_quantum_register",test_fail_create_quantum_register)
    ]
    #endif

    private var QPS_SPECS: [String:Any] = [:]

    override func setUp() {
        super.setUp()
        self.QPS_SPECS = [
            "circuits": [[
            "name": "circuitName",
            "quantum_registers": [[
            "name": "qname",
            "size": 3]],
            "classical_registers": [[
            "name": "cname",
            "size": 3]]
            ]]
        ]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_fail_create_quantum_register() {
        do {
            let QP_program = try QuantumProgram()
            try QP_program.create_quantum_register("qr", 3)
            XCTAssertThrowsError(try QP_program.create_quantum_register("qr", 2)) { (error) -> Void in
                switch error {
                case QISKitError.registerSize:
                    break
                default:
                    XCTFail("test_fail_create_quantum_register: \(error)")
                }
            }
        } catch {
            XCTFail("test_fail_create_quantum_register: \(error)")
        }
    }
}
