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
 Tests for QI.
 */
class QITests: XCTestCase {

    static let allTests = [
        ("test_trial_functions",test_trial_functions),
        ("test_partial_trace",test_partial_trace)
    ]

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_trial_functions() {
        do {
            let entangler_map: [Int: [Int]] = [0: [2], 1: [2], 3: [2], 4: [2]]

            let m = 1
            let n = 6
            let theta = [Double](repeating:0.0, count: m * n)

            var trial_circuit = try Optimization.trial_circuit_ry(n, m, theta, entangler_map)

            SDKLogger.logInfo(trial_circuit.qasm())

            SDKLogger.logInfo("With No measurement:\n")
            trial_circuit = try Optimization.trial_circuit_ry(n, m, theta, entangler_map)

            SDKLogger.logInfo(trial_circuit.qasm())

            SDKLogger.logInfo("With Y measurement:\n")
            let meas_sting = String(repeatElement("Y", count: n))

            trial_circuit = try Optimization.trial_circuit_ry(n, m, theta, entangler_map, meas_sting)

            SDKLogger.logInfo(trial_circuit.qasm())
        } catch {
            XCTFail("test_trial_functions: \(error)")
        }
    }

    func test_partial_trace() {
        do {
            // reference
            let rho0 = Matrix<Complex>(value:[[0.5, 0.5], [0.5, 0.5]])
            let rho1 = Matrix<Complex>(value:[[1, 0], [0, 0]])
            let rho2 = Matrix<Complex>(value:[[0, 0], [0, 1]])
            let rho10 = rho1.kron(rho0)
            let rho20 = rho2.kron(rho0)
            let rho21 = rho2.kron(rho1)
            let rho210 = rho21.kron(rho0)
            let rhos = [rho0, rho1, rho2, rho10, rho20, rho21]

            // test partial trace
            let tau0 = try QI.partial_trace(rho210.value, sys: [1, 2])
            let tau1 = try QI.partial_trace(rho210.value, sys: [0, 2])
            let tau2 = try QI.partial_trace(rho210.value, sys: [0, 1])

            // test different dimensions
            let tau10 = try QI.partial_trace(rho210.value, sys: [1], dims: [4, 2])
            let tau20 = try QI.partial_trace(rho210.value, sys: [1], dims: [2, 2, 2])
            let tau21 = try QI.partial_trace(rho210.value, sys: [0], dims: [2, 4])
            let taus = [tau0, tau1, tau2, tau10, tau20, tau21]

            var all_pass = true
            for (i, j) in zip(rhos, taus) {
                let norm = try i.subtract(j).norm()
                all_pass = all_pass && (norm == 0)
            }
            XCTAssert(all_pass)
        } catch {
            XCTFail("test_partial_trace: \(error)")
        }
    }
/*
    func test_vectorize() {
        let mat = [[1, 2], [3, 4]]
        let col = [1, 3, 2, 4]
        let row = [1, 2, 3, 4]
        let paul = [5, 5, -1j, -3]
        let test_pass = np.linalg.norm(vectorize(mat) - col) == 0 &&
        np.linalg.norm(vectorize(mat, method='col') - col) == 0 &&
        np.linalg.norm(vectorize(mat, method='row') - row) == 0 &&
        np.linalg.norm(vectorize(mat, method='pauli') - paul) == 0
        XCTAssert(test_pass)
    }

    func test_devectorize() {
        let mat = [[1, 2], [3, 4]]
        let col = [1, 3, 2, 4]
        let row = [1, 2, 3, 4]
        let paul = [5, 5, -1j, -3]
        let test_pass = np.linalg.norm(devectorize(col) - mat) == 0 &&
        np.linalg.norm(devectorize(col, method='col') - mat) == 0 &&
        np.linalg.norm(devectorize(row, method='row') - mat) == 0 &&
        np.linalg.norm(devectorize(paul, method='pauli') - mat) == 0
        XCTAssert(test_pass)
    }

    func test_outer() {
        let v_z = [1, 0]
        let v_y = [1, 1j]
        let rho_z = [[1, 0], [0, 0]]
        let rho_y = [[1, -1j], [1j, 1]]
        let op_zy = [[1, -1j], [0, 0]]
        let op_yz = [[1, 0], [1j, 0]]
        let test_pass = np.linalg.norm(outer(v_z) - rho_z) == 0 &&
        np.linalg.norm(outer(v_y) - rho_y) == 0 &&
        np.linalg.norm(outer(v_y, v_z) - op_yz) == 0 &&
        np.linalg.norm(outer(v_z, v_y) - op_zy) == 0
        XCTAssert(test_pass)
    }

    func test_state_fidelity() {
        let psi1 = [0.70710678118654746, 0, 0, 0.70710678118654746]
        let psi2 = [0., 0.70710678118654746, 0.70710678118654746, 0.]
        let rho1 = [[0.5, 0, 0, 0.5], [0, 0, 0, 0], [0, 0, 0, 0], [0.5, 0, 0, 0.5]]
        let mix = [[0.25, 0, 0, 0], [0, 0.25, 0, 0],
                   [0, 0, 0.25, 0], [0, 0, 0, 0.25]]
        let test_pass = round(state_fidelity(psi1, psi1), 7) == 1.0 &&
        round(state_fidelity(psi1, psi2), 8) == 0.0 &&
        round(state_fidelity(psi1, rho1), 8) == 1.0 &&
        round(state_fidelity(psi1, mix), 8) == 0.5 &&
        round(state_fidelity(psi2, rho1), 8) == 0.0 &&
        round(state_fidelity(psi2, mix), 8) == 0.5 &&
        round(state_fidelity(rho1, rho1), 8) == 1.0 &&
        round(state_fidelity(rho1, mix), 8) == 0.5 &&
        round(state_fidelity(mix, mix), 8) == 1.0
        XCTAssert(test_pass)
    }

    func test_purity() {
        let rho1 = [[1, 0], [0, 0]]
        let rho2 = [[0.5, 0], [0, 0.5]]
        let rho3 = 0.7 * np.array(rho1) + 0.3 * np.array(rho2)
        let test_pass = purity(rho1) == 1.0 &&
        purity(rho2) == 0.5 &&
        round(purity(rho3), 10) == 0.745
        XCTAssert(test_pass)
    }

    func test_concurrence() {
        let psi1 = [1, 0, 0, 0]
        let rho1 = [[0.5, 0, 0, 0.5], [0, 0, 0, 0], [0, 0, 0, 0], [0.5, 0, 0, 0.5]]
        let rho2 = [[0, 0, 0, 0], [0, 0.5, -0.5j, 0],
                    [0, 0.5j, 0.5, 0], [0, 0, 0, 0]]
        let rho3 = 0.5 * np.array(rho1) + 0.5 * np.array(rho2)
        let rho4 = 0.75 * np.array(rho1) + 0.25 * np.array(rho2)
        let test_pass = concurrence(psi1) == 0.0 &&
        concurrence(rho1) == 1.0 &&
        concurrence(rho2) == 1.0 &&
        concurrence(rho3) == 0.0 &&
        concurrence(rho4) == 0.5
        XCTAssert(test_pass)
    }*/
}
