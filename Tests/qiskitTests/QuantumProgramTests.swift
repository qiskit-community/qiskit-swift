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

    //#if os(Linux)
    static let allTests = [
        ("test_create_program_with_specs",test_create_program_with_specs),
        ("test_create_program",test_create_program),
        ("test_create_classical_register",test_create_classical_register),
        ("test_create_quantum_register",test_create_quantum_register),
        ("test_fail_create_quantum_register",test_fail_create_quantum_register),
        ("test_fail_create_classical_register",test_fail_create_classical_register),
        ("test_create_quantum_register_same",test_create_quantum_register_same),
        ("test_create_classical_register_same",test_create_classical_register_same),
        ("test_create_classical_registers",test_create_classical_registers),
        ("test_create_quantum_registers",test_create_quantum_registers),
        ("test_create_circuit",test_create_circuit),
        ("test_create_several_circuits",test_create_several_circuits),
        ("test_load_qasm_file",test_load_qasm_file),
        ("test_fail_load_qasm_file",test_fail_load_qasm_file),
        ("test_load_qasm_text",test_load_qasm_text),
        ("test_get_register_and_circuit",test_get_register_and_circuit),
        ("test_get_register_and_circuit_names",test_get_register_and_circuit_names),
        ("test_get_qasm",test_get_qasm),
        ("test_get_qasms",test_get_qasms),
        ("test_get_qasm_all_gates",test_get_qasm_all_gates),
        ("test_get_initial_circuit",test_get_initial_circuit),
        ("test_save",test_save),
        ("test_save_wrong",test_save_wrong),
        ("test_load",test_load),
        ("test_setup_api",test_setup_api),
        ("test_available_backends_exist",test_available_backends_exist),
        ("test_local_backends_exist",test_local_backends_exist),
        ("test_online_backends_exist",test_online_backends_exist),
        ("test_online_devices",test_online_devices),
        ("test_online_simulators",test_online_simulators),
        ("test_backend_status",test_backend_status),
        ("test_get_backend_configuration",test_get_backend_configuration),
        ("test_get_backend_configuration_fail",test_get_backend_configuration_fail),
        ("test_get_backend_calibration",test_get_backend_calibration),
        ("test_get_backend_parameters",test_get_backend_parameters),
        ("test_compile_program",test_compile_program),
        ("test_get_compiled_configuration",test_get_compiled_configuration),
        ("test_get_compiled_qasm",test_get_compiled_qasm),
        ("test_get_execution_list",test_get_execution_list),
        ("test_compile_coupling_map",test_compile_coupling_map)
    ]
    //#endif

    private var QE_TOKEN: String? = nil
    private var QE_URL = Qconfig.BASEURL
    private var QPS_SPECS: [String:Any] = [:]
    private var QASM_FILE_PATH: String = ""
    private var QASM_FILE_PATH_2: String = ""

    override func setUp() {
        super.setUp()
        let environment = ProcessInfo.processInfo.environment
        if let token = environment["QE_TOKEN"] {
            self.QE_TOKEN = token
        }
        if let url = environment["QE_URL"] {
            self.QE_URL = url
        }
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
        self.QASM_FILE_PATH = self._get_resource_path("entangled_registers.qasm")
        self.QASM_FILE_PATH_2 = self._get_resource_path("plaquette_check.qasm")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func _get_resource_path(_ filename: String) -> String {
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        return path.path
    }

    //###############################################################
    //# Tests to initiate an build a quantum program
    //###############################################################

    func test_create_program_with_specs() {
        do {
            let result = try QuantumProgram(specs: self.QPS_SPECS)
            SDKLogger.logInfo(result)
        } catch {
            XCTFail("test_create_program_with_specs: \(error)")
        }
    }

    func test_create_program() {
        do {
            let result = try QuantumProgram()
            SDKLogger.logInfo(result)
        } catch {
            XCTFail("test_create_program: \(error)")
        }
    }

    func test_create_classical_register() {
        do {
            let QP_program = try QuantumProgram()
            let cr = try QP_program.create_classical_register("cr", 3)
            SDKLogger.logInfo(cr)
        } catch {
            XCTFail("test_create_classical_register: \(error)")
        }
    }

    func test_create_quantum_register() {
        do {
            let QP_program = try QuantumProgram()
            let qr = try QP_program.create_quantum_register("qr", 3)
            SDKLogger.logInfo(qr)
        } catch {
            XCTFail("test_create_quantum_register: \(error)")
        }
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

    func test_fail_create_classical_register() {
         do {
            let QP_program = try QuantumProgram()
            try QP_program.create_classical_register("cr", 3)
            XCTAssertThrowsError(try QP_program.create_classical_register("cr", 2)) { (error) -> Void in
                switch error {
                case QISKitError.registerSize:
                    break
                default:
                    XCTFail("test_fail_create_quantum_register: \(error)")
                }
            }
         } catch {
            XCTFail("test_fail_create_classical_register: \(error)")
        }
    }

    func test_create_quantum_register_same() {
        do {
            let QP_program = try QuantumProgram()
            let qr1 = try QP_program.create_quantum_register("qr", 3)
            let qr2 = try QP_program.create_quantum_register("qr", 3)
            XCTAssertEqual(qr1, qr2)
        } catch {
            XCTFail("test_create_quantum_register_same: \(error)")
        }
    }

    func test_create_classical_register_same() {
        do {
            let QP_program = try QuantumProgram()
            let cr1 = try QP_program.create_classical_register("cr", 3)
            let cr2 = try QP_program.create_classical_register("cr", 3)
            XCTAssertEqual(cr1, cr2)
        } catch {
            XCTFail("test_create_classical_register_same: \(error)")
        }
    }

    func test_create_classical_registers() {
         do {
            let QP_program = try QuantumProgram()
            let classical_registers = [["name": "c1", "size": 4],
                                       ["name": "c2", "size": 2]]
            let crs = try QP_program.create_classical_registers(classical_registers)
            for i in crs {
                SDKLogger.logInfo(i)
            }
         } catch {
            XCTFail("test_create_classical_registers: \(error)")
        }
    }

    func test_create_quantum_registers() {
        do {
            let QP_program = try QuantumProgram()
            let quantum_registers = [["name": "q1", "size": 4],
                                     ["name": "q2", "size": 2]]
            let qrs = try QP_program.create_quantum_registers(quantum_registers)
            for i in qrs {
                SDKLogger.logInfo(i)
            }
        } catch {
            XCTFail("test_create_quantum_registers: \(error)")
        }
    }

    func test_create_circuit() {
        do {
            let QP_program = try QuantumProgram()
            let qr = try QP_program.create_quantum_register("qr", 3)
            let cr = try QP_program.create_classical_register("cr", 3)
            let qc = try QP_program.create_circuit("qc", [qr], [cr])
            SDKLogger.logInfo(qc)
        } catch {
            XCTFail("test_create_circuit: \(error)")
        }
    }

    func test_create_several_circuits() {
        do {
            let QP_program = try QuantumProgram()
            let qr1 = try QP_program.create_quantum_register("qr1", 3)
            let cr1 = try QP_program.create_classical_register("cr1", 3)
            let qr2 = try QP_program.create_quantum_register("qr2", 3)
            let cr2 = try QP_program.create_classical_register("cr2", 3)
            let qc1 = try QP_program.create_circuit("qc1", [qr1], [cr1])
            let qc2 = try QP_program.create_circuit("qc2", [qr2], [cr2])
            let qc3 = try QP_program.create_circuit("qc2", [qr1, qr2], [cr1, cr2])
            SDKLogger.logInfo(qc1)
            SDKLogger.logInfo(qc2)
            SDKLogger.logInfo(qc3)
        } catch {
            XCTFail("test_create_several_circuits: \(error)")
        }
    }

    func test_load_qasm_file() {
        do {
            try EntangledRegisters.QASM.write(toFile: self.QASM_FILE_PATH, atomically: true, encoding: .utf8)
            let QP_program = try QuantumProgram()
            let name = try QP_program.load_qasm_file(self.QASM_FILE_PATH, name:"")
            let result = try QP_program.get_circuit(name)
            let to_check = result.qasm()
            SDKLogger.logInfo(to_check)
            XCTAssertEqual(to_check.count, 554)
        } catch {
            XCTFail("test_load_qasm_file: \(error)")
        }
    }

    func test_fail_load_qasm_file() {
        do {
            let QP_program = try QuantumProgram()
            XCTAssertThrowsError(try QP_program.load_qasm_file("")) { (error) -> Void in
                switch error {
                case QasmError.internalError(let error):
                    SDKLogger.logInfo(error.localizedDescription)
                default:
                    XCTFail("test_fail_load_qasm_file: \(error)")
                }
            }
        } catch {
            XCTFail("test_fail_load_qasm_file: \(error)")
        }
    }

    func test_load_qasm_text() {
        do {
            let QP_program = try QuantumProgram()
            var QASM_string = "// A simple 8 qubit example\nOPENQASM 2.0;\n"
            QASM_string += "include \"qelib1.inc\";\nqreg a[4];\n"
            QASM_string += "qreg b[4];\ncreg c[4];\ncreg d[4];\nh a;\ncx a, b;\n"
            QASM_string += "barrier a;\nbarrier b;\nmeasure a[0]->c[0];\n"
            QASM_string += "measure a[1]->c[1];\nmeasure a[2]->c[2];\n"
            QASM_string += "measure a[3]->c[3];\nmeasure b[0]->d[0];\n"
            QASM_string += "measure b[1]->d[1];\nmeasure b[2]->d[2];\n"
            QASM_string += "measure b[3]->d[3];"
            let name = try QP_program.load_qasm_text(QASM_string)
            let result = try QP_program.get_circuit(name)
            let to_check = result.qasm()
            SDKLogger.logInfo(to_check)
            XCTAssertEqual(to_check.count, 554)
        } catch {
            XCTFail("test_load_qasm_text: \(error)")
        }
    }

    func test_get_register_and_circuit() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            SDKLogger.logInfo(qc)
            SDKLogger.logInfo(qr)
            SDKLogger.logInfo(cr)
        } catch {
            XCTFail("test_get_register_and_circuit: \(error)")
        }
    }

    func test_get_register_and_circuit_names() {
        do {
            let QP_program = try QuantumProgram()
            let qr1 = try QP_program.create_quantum_register("qr1", 3)
            let cr1 = try QP_program.create_classical_register("cr1", 3)
            let qr2 = try QP_program.create_quantum_register("qr2", 3)
            let cr2 = try QP_program.create_classical_register("cr2", 3)
            try QP_program.create_circuit("qc1", [qr1], [cr1])
            try QP_program.create_circuit("qc2", [qr2], [cr2])
            try QP_program.create_circuit("qc2", [qr1, qr2], [cr1, cr2])
            let qrn = QP_program.get_quantum_register_names()
            let crn = QP_program.get_classical_register_names()
            let qcn = QP_program.get_circuit_names()
            XCTAssertEqual(qrn, ["qr1", "qr2"])
            XCTAssertEqual(crn, ["cr1", "cr2"])
            XCTAssertEqual(qcn, ["qc1", "qc2"])
        } catch {
            XCTFail("test_get_register_and_circuit_names: \(error)")
        }
    }

    func test_get_qasm() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.h(qr[0])
            try qc.cx(qr[0], qr[1])
            try qc.cx(qr[1], qr[2])
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            try qc.measure(qr[2], cr[2])
            let result = try QP_program.get_qasm("circuitName")
            XCTAssertEqual(result.count, 212)
        } catch {
            XCTFail("test_get_qasm: \(error)")
        }
    }

    func test_get_qasms() {
         do {
            let QP_program = try QuantumProgram()
            let qr = try QP_program.create_quantum_register("qr", 3)
            let cr = try QP_program.create_classical_register("cr", 3)
            let qc1 = try QP_program.create_circuit("qc1", [qr], [cr])
            let qc2 = try QP_program.create_circuit("qc2", [qr], [cr])
            try qc1.h(qr[0])
            try qc1.cx(qr[0], qr[1])
            try qc1.cx(qr[1], qr[2])
            try qc1.measure(qr[0], cr[0])
            try qc1.measure(qr[1], cr[1])
            try qc1.measure(qr[2], cr[2])
            try qc2.h(qr)
            try qc2.measure(qr[0], cr[0])
            try qc2.measure(qr[1], cr[1])
            try qc2.measure(qr[2], cr[2])
            let result = try QP_program.get_qasms(["qc1", "qc2"])
            XCTAssertEqual(result[0].count, 173)
            XCTAssertEqual(result[1].count, 159)
        } catch {
            XCTFail("test_get_qasms: \(error)")
        }
    }

    func test_get_qasm_all_gates() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.u1(0.3, qr[0])
            try qc.u2(0.2, 0.1, qr[1])
            try qc.u3(0.3, 0.2, 0.1, qr[2])
            try qc.s(qr[1])
            try qc.s(qr[2]).inverse()
            try qc.cx(qr[1], qr[2])
            try qc.barrier()
            try qc.cx(qr[0], qr[1])
            try qc.h(qr[0])
            try qc.x(qr[2]).c_if(cr, 0)
            try qc.y(qr[2]).c_if(cr, 1)
            try qc.z(qr[2]).c_if(cr, 2)
            try qc.barrier(qr)
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            try qc.measure(qr[2], cr[2])
            let result = try QP_program.get_qasm("circuitName")
            XCTAssertEqual(result.count, 535)
        } catch {
            XCTFail("test_get_qasm_all_gates: \(error)")
        }
    }

    func test_get_initial_circuit() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            guard let qc = QP_program.get_initial_circuit() else {
                XCTFail("test_get_initial_circuit: Missing initial circuit")
                return
            }
            SDKLogger.logInfo(qc)
        } catch {
            XCTFail("test_get_initial_circuit: \(error)")
        }
    }

    func test_save() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.u3(0.3, 0.2, 0.1, qr[0])
            try qc.h(qr[1])
            try qc.cx(qr[1], qr[2])
            try qc.barrier()
            try qc.cx(qr[0], qr[1])
            try qc.h(qr[0])
            try qc.z(qr[2]).c_if(cr, 1)
            try qc.x(qr[2]).c_if(cr, 1)
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            let result = try QP_program.save(self._get_resource_path("test_save.json"),beauty: true)
            SDKLogger.logInfo(result)
        } catch {
            XCTFail("test_save: \(error)")
        }
    }

    func test_save_wrong() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            XCTAssertThrowsError(try QP_program.save("")) { (error) -> Void in
                switch error {
                case QISKitError.internalError(let error):
                    SDKLogger.logInfo(error.localizedDescription)
                default:
                    XCTFail("test_save_wrong: \(error)")
                }
            }
        } catch {
            XCTFail("test_save_wrong: \(error)")
        }
    }

    func test_load() {
        do {
            var QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            try QP_program.load_qasm_text(EntangledRegisters.QASM, name: "circuitName")
            try QP_program.save(self._get_resource_path("test_save.json"),beauty: true)
            QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let result = try QP_program.load(self._get_resource_path("test_save.json"))
            SDKLogger.logInfo(result)
            let check_result = try QP_program.get_qasm("circuitName")
            XCTAssertEqual(check_result.count, 554)
        } catch {
            XCTFail("test_load: \(error)")
        }
    }

    //###############################################################
    //# Tests for working with backends
    //###############################################################

    func test_setup_api() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            try QP_program.set_api(token:token, url:QE_URL)
            let config = QP_program.get_api_config()
            SDKLogger.logInfo(config)
        } catch {
            XCTFail("test_setup_api: \(error)")
        }
    }

    func test_available_backends_exist() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            try QP_program.set_api(token:token, url:QE_URL)
            let asyncExpectation = self.expectation(description: "test_available_backends_exist")
            QP_program.available_backends() { (available_backends,error) in
                if error != nil {
                    XCTFail("Failure in test_available_backends_exist: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(available_backends)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_available_backends_exist")
            })
        } catch {
            XCTFail("test_available_backends_exist: \(error)")
        }
    }

    func test_local_backends_exist() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let local_backends = QP_program.local_backends()
            SDKLogger.logInfo(local_backends)
        } catch {
            XCTFail("test_local_backends_exist: \(error)")
        }
    }

    func test_online_backends_exist() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            // TODO: should we check if we the QX is online before running
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            try QP_program.set_api(token:token, url:QE_URL)
            let asyncExpectation = self.expectation(description: "test_available_backends_exist")
            QP_program.online_backends()  { (online_backends,error) in
                if error != nil {
                    XCTFail("Failure in test_online_backends_exist: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(online_backends)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_online_backends_exist")
            })
        } catch {
            XCTFail("test_online_backends_exist: \(error)")
        }
    }

    func test_online_devices() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            // TODO: should we check if we the QX is online before running
            let qp = try QuantumProgram(specs: self.QPS_SPECS)
            try qp.set_api(token:token, url:QE_URL)
            let asyncExpectation = self.expectation(description: "test_online_devices")
            qp.online_devices()  { (online_devices,error) in
                if error != nil {
                    XCTFail("Failure in test_online_devices: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(online_devices)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_online_devices")
            })
        } catch {
            XCTFail("test_online_devices: \(error)")
        }
    }

    func test_online_simulators() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            // TODO: should we check if we the QX is online before running
            let qp = try QuantumProgram(specs: self.QPS_SPECS)
            try qp.set_api(token:token, url:QE_URL)
            let asyncExpectation = self.expectation(description: "test_online_simulators")
            qp.online_simulators() { (online_simulators,error) in
                if error != nil {
                    XCTFail("Failure in test_online_simulators: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(online_simulators)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_online_devices")
            })
        } catch {
            XCTFail("test_online_simulators: \(error)")
        }
    }

    func test_backend_status() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let asyncExpectation = self.expectation(description: "test_backend_status")
            QP_program.get_backend_status("local_qasm_simulator") { (status,error) in
                if error != nil {
                    XCTFail("Failure in test_backend_status: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(status)
                guard let available = status["available"] as? Bool else {
                    XCTFail("test_backend_status: Missing status.")
                    asyncExpectation.fulfill()
                    return
                }
                XCTAssertEqual(available, true)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_backend_status")
            })
        } catch {
            XCTFail("test_backend_status: \(error)")
        }
    }

    func test_get_backend_configuration() {
        do {
            let qp = try QuantumProgram(specs: self.QPS_SPECS)
            let config_keys = ["name", "simulator", "local", "description",
                               "coupling_map", "basis_gates"]
            let asyncExpectation = self.expectation(description: "test_get_backend_configuration")
            qp.get_backend_configuration("local_qasm_simulator")  { (backend_config,error) in
                if error != nil {
                    XCTFail("Failure in test_get_backend_configuration: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(backend_config)
                XCTAssert(config_keys.count < backend_config.keys.count)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_get_backend_configuration")
            })
        } catch {
            XCTFail("test_get_backend_configuration: \(error)")
        }
    }

    func test_get_backend_configuration_fail() {
        do {
            let qp = try QuantumProgram(specs: self.QPS_SPECS)
            let asyncExpectation = self.expectation(description: "test_get_backend_configuration_fail")
            qp.get_backend_configuration("fail")  { (backend_config,error) in
                if error != nil {
                    switch error! {
                    case IBMQuantumExperienceError.badBackendError(let backend):
                        SDKLogger.logInfo(backend)
                        break
                    default:
                        XCTFail("test_get_backend_configuration_fail: \(error!)")
                    }
                    asyncExpectation.fulfill()
                    return
                }
                SDKLogger.logInfo(backend_config)
                XCTFail("test_get_backend_configuration_fail should have failed.")
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_get_backend_configuration_fail")
            })
        } catch {
            XCTFail("test_get_backend_configuration_fail: \(error)")
        }
    }

    func test_get_backend_calibration() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            try QP_program.set_api(token:token, url:QE_URL)
            let asyncExpectation = self.expectation(description: "test_get_backend_calibration")
            QP_program.online_backends() { (backend_list,error) in
                if error != nil {
                    XCTFail("Failure in test_get_backend_calibration: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                if let backend = backend_list.first {
                    QP_program.get_backend_calibration(backend)  { (result,error) in
                        if error != nil {
                            XCTFail("Failure in test_get_backend_calibration: \(error!.localizedDescription)")
                            asyncExpectation.fulfill()
                            return
                        }
                        SDKLogger.logInfo(result)
                        XCTAssertEqual(result.count, 4)
                        asyncExpectation.fulfill()
                    }
                }
                else {
                    asyncExpectation.fulfill()
                }
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_get_backend_calibration")
            })
        } catch {
            XCTFail("test_get_backend_calibration: \(error)")
        }
    }

    func test_get_backend_parameters() {
        guard let token = self.QE_TOKEN else {
            return
        }
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            try QP_program.set_api(token:token, url:QE_URL)
            let asyncExpectation = self.expectation(description: "test_get_backend_parameters")
            QP_program.online_backends() { (backend_list,error) in
                if error != nil {
                    XCTFail("Failure in test_get_backend_parameters: \(error!.localizedDescription)")
                    asyncExpectation.fulfill()
                    return
                }
                if let backend = backend_list.first {
                    QP_program.get_backend_parameters(backend)  { (result,error) in
                        if error != nil {
                            XCTFail("Failure in test_get_backend_parameters: \(error!.localizedDescription)")
                            asyncExpectation.fulfill()
                            return
                        }
                        SDKLogger.logInfo(result)
                        XCTAssertEqual(result.count, 4)
                        asyncExpectation.fulfill()
                    }
                }
                else {
                    asyncExpectation.fulfill()
                }
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_get_backend_parameters")
            })
        } catch {
            XCTFail("test_get_backend_parameters: \(error)")
        }
    }

    //###############################################################
    //# Test for compile
    //###############################################################

    func test_compile_program() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.h(qr[0])
            try qc.cx(qr[0], qr[1])
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            let backend = "test"
            let coupling_map: [Int:[Int]]? = nil
            let out = try QP_program.compile(["circuitName"], backend: backend,
                                         coupling_map: coupling_map, qobj_id: "cooljob")
            SDKLogger.logInfo(out)
            XCTAssertEqual(out.count, 3)
        } catch {
            XCTFail("test_compile_program: \(error)")
        }
    }

    func test_get_compiled_configuration() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.h(qr[0])
            try qc.cx(qr[0], qr[1])
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            let backend = "local_qasm_simulator"
            let coupling_map: [Int:[Int]]? = nil
            let qobj = try QP_program.compile(["circuitName"], backend: backend,
                                          coupling_map: coupling_map)
            let result = try QP_program.get_compiled_configuration(qobj, "circuitName")
            SDKLogger.logInfo(result)
            XCTAssertEqual(result.count, 4)
        } catch {
            XCTFail("test_compile_program: \(error)")
        }
    }

    func test_get_compiled_qasm() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.h(qr[0])
            try qc.cx(qr[0], qr[1])
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            let backend = "local_qasm_simulator"
            let coupling_map: [Int:[Int]]? = nil
            let qobj = try QP_program.compile(["circuitName"], backend: backend,
                                              coupling_map: coupling_map)
            let result = try QP_program.get_compiled_qasm(qobj, "circuitName")
            SDKLogger.logInfo(result)
            XCTAssertEqual(result.count, 184)
        } catch {
            XCTFail("test_get_compiled_qasm: \(error)")
        }
    }

    func test_get_execution_list() {
        do {
            let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
            let qc = try QP_program.get_circuit("circuitName")
            let qr = try QP_program.get_quantum_register("qname")
            let cr = try QP_program.get_classical_register("cname")
            try qc.h(qr[0])
            try qc.cx(qr[0], qr[1])
            try qc.measure(qr[0], cr[0])
            try qc.measure(qr[1], cr[1])
            let backend = "local_qasm_simulator"
            let coupling_map: [Int:[Int]]? = nil
            let qobj = try QP_program.compile(["circuitName"], backend: backend,
                                          coupling_map: coupling_map, qobj_id: "cooljob")
            let result = QP_program.get_execution_list(qobj)
            SDKLogger.logInfo(result)
            XCTAssertEqual(result, ["circuitName"])
        } catch {
            XCTFail("test_get_execution_list: \(error)")
        }
    }

    func test_compile_coupling_map() {
        do {
            let QP_program = try QuantumProgram()
            let q = try QP_program.create_quantum_register("q", 3)
            let c = try QP_program.create_classical_register("c", 3)
            let qc = try QP_program.create_circuit("circuitName", [q], [c])
            try qc.h(q[0])
            try qc.cx(q[0], q[1])
            try qc.cx(q[0], q[2])
            try qc.measure(q[0], c[0])
            try qc.measure(q[1], c[1])
            try qc.measure(q[2], c[2])
            let backend = "local_qasm_simulator"  // the backend to run on
            let shots = 1024  // the number of shots in the experiment.
            let coupling_map = [0: [1], 1: [2]]
            let initial_layout:OrderedDictionary<RegBit,RegBit> = [RegBit(("q", 0)): RegBit(("q", 0)),
                                                                   RegBit(("q", 1)): RegBit(("q", 1)),
                                                                   RegBit(("q", 2)): RegBit(("q", 2))]
            let circuits = ["circuitName"]
            let qobj = try QP_program.compile(circuits, backend: backend,
                                          coupling_map: coupling_map, initial_layout: initial_layout,
                                          shots: shots, seed: 88)
            let asyncExpectation = self.expectation(description: "test_compile_coupling_map")
            QP_program.run_async(qobj) { (result) in
                do {
                    if result.is_error() {
                        XCTFail("Failure in runJob: \(result.get_error())")
                        asyncExpectation.fulfill()
                        return
                    }
                    let to_check = try QP_program.get_qasm("circuitName")
                    XCTAssertEqual(to_check.count, 160)
                    XCTAssertEqual(try result.get_counts("circuitName"), ["000": 518, "111": 506])
                    asyncExpectation.fulfill()
                } catch {
                    XCTFail("Failure in test_compile_coupling_map: \(error)")
                    asyncExpectation.fulfill()
                }
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_compile_coupling_map")
            })
        } catch {
            XCTFail("test_compile_coupling_map: \(error)")
        }
    }
/*
    func test_change_circuit_qobj_after_compile() {
    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc2.cx(qr[0], qr[2])
    qc3.h(qr)
    qc2.measure(qr, cr)
    qc3.measure(qr, cr)
    circuits = ["qc2", "qc3"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    config = ["seed": 10, "shots": 1, "xvals":[1, 2, 3, 4]]
    qobj1 = QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88, config=config)
    qobj1["circuits"][0]["config"]["shots"] = 50
    qobj1["circuits"][0]["config"]["xvals"] = [1,1,1]
    config["shots"] = 1000
    config["xvals"][0] = "only for qobj2"
    qobj2 = QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88, config=config)
    self.assertTrue(qobj1["circuits"][0]["config"]["shots"] == 50)
    self.assertTrue(qobj1["circuits"][1]["config"]["shots"] == 1)
    self.assertTrue(qobj1["circuits"][0]["config"]["xvals"] == [1,1,1])
    self.assertTrue(qobj1["circuits"][1]["config"]["xvals"] == [1,2,3,4])
    self.assertTrue(qobj1["config"]["shots"] == 1024)
    self.assertTrue(qobj2["circuits"][0]["config"]["shots"] == 1000)
    self.assertTrue(qobj2["circuits"][1]["config"]["shots"] == 1000)
    self.assertTrue(qobj2["circuits"][0]["config"]["xvals"] == [
    "only for qobj2", 2, 3, 4])
    self.assertTrue(qobj2["circuits"][1]["config"]["xvals"] == [
    "only for qobj2", 2, 3, 4])
    }

    //###############################################################
    //# Test for running programs
    //###############################################################

    func test_run_program() {
    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc2.cx(qr[0], qr[2])
    qc3.h(qr)
    qc2.measure(qr, cr)
    qc3.measure(qr, cr)
    circuits = ["qc2", "qc3"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    qobj = QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88)
    out = QP_program.run(qobj)
    results2 = out.get_counts("qc2")
    results3 = out.get_counts("qc3")
    XCTAssertEqual(results2, ["000": 518, "111": 506])
    XCTAssertEqual(results3, ["001": 119, "111": 129, "110": 134,
    "100": 117, "000": 129, "101": 126,
    "010": 145, "011": 125])

    }

    func test_run_async_program() {
    }

    func _job_done_callback(_ result: Result) {
    results2 = result.get_counts("qc2")
    results3 = result.get_counts("qc3")
    XCTAssertEqual(results2, ["000": 518, "111": 506])
    XCTAssertEqual(results3, ["001": 119, "111": 129, "110": 134,
    "100": 117, "000": 129, "101": 126,
    "010": 145, "011": 125])
    except Exception as e:
    self.qp_program_exception = e
    finally:
    self.qp_program_finished = True

    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc2.cx(qr[0], qr[2])
    qc3.h(qr)
    qc2.measure(qr, cr)
    qc3.measure(qr, cr)
    circuits = ["qc2", "qc3"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    qobj = QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88)

    self.qp_program_finished = False
    self.qp_program_exception = None
    out = QP_program.run_async(qobj, callback=_job_done_callback)

        while not self.qp_program_finished {
            // Wait until the job_done_callback is invoked and completed.
            pass
        }
        if self.qp_program_exception {
            raise self.qp_program_exception
        }
    }

    func test_run_batch() {
    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc2.cx(qr[0], qr[2])
    qc3.h(qr)
    qc2.measure(qr, cr)
    qc3.measure(qr, cr)
    circuits = ["qc2", "qc3"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    qobj_list = [ QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88),
    QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88),
    QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88),
    QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88) ]

    results = QP_program.run_batch(qobj_list)
    for result in results:
    counts2 = result.get_counts("qc2")
    counts3 = result.get_counts("qc3")
    XCTAssertEqual(counts2, ["000": 518, "111": 506])
    XCTAssertEqual(counts3, ["001": 119, "111": 129, "110": 134,
    "100": 117, "000": 129, "101": 126,
    "010": 145, "011": 125])

    }

    func test_run_batch_async() {
    }

    func _jobs_done_callback(results):

    for result in results:
    counts2 = result.get_counts("qc2")
    counts3 = result.get_counts("qc3")
    XCTAssertEqual(counts2, ["000": 518, "111": 506])
    XCTAssertEqual(counts3, ["001": 119, "111": 129,
    "110": 134, "100": 117,
    "000": 129, "101": 126,
    "010": 145, "011": 125])
    except Exception as e:
    self.qp_program_exception = e
    finally:
    self.qp_program_finished = True

    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc2.cx(qr[0], qr[2])
    qc3.h(qr)
    qc2.measure(qr, cr)
    qc3.measure(qr, cr)
    circuits = ["qc2", "qc3"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    qobj_list = [ QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88),
    QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88),
    QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88),
    QP_program.compile(circuits, backend=backend, shots=shots,
    seed=88) ]

    self.qp_program_finished = False
    self.qp_program_exception = None
    results = QP_program.run_batch_async(qobj_list,
    callback=_jobs_done_callback)
    while not self.qp_program_finished {
    // Wait until the job_done_callback is invoked and completed.
        pass
    }
    if self.qp_program_exception {
        raise self.qp_program_exception
    }
    }

    func test_combine_results() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("qr", 1)
    cr = QP_program.create_classical_register("cr", 1)
    qc1 = QP_program.create_circuit("qc1", [qr], [cr])
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc1.measure(qr[0], cr[0])
    qc2.x(qr[0])
    qc2.measure(qr[0], cr[0])
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    res1 = QP_program.execute(["qc1"], backend=backend, shots=shots)
    res2 = QP_program.execute(["qc2"], backend=backend, shots=shots)
    counts1 = res1.get_counts("qc1")
    counts2 = res2.get_counts("qc2")
    res1 += res2  # combine results
    counts12 = [res1.get_counts("qc1"), res1.get_counts("qc2")]
    XCTAssertEqual(counts12, [counts1, counts2])

    }

    func test_local_qasm_simulator() {
    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc2.cx(qr[0], qr[2])
    qc3.h(qr)
    qc2.measure(qr[0], cr[0])
    qc3.measure(qr[0], cr[0])
    qc2.measure(qr[1], cr[1])
    qc3.measure(qr[1], cr[1])
    qc2.measure(qr[2], cr[2])
    qc3.measure(qr[2], cr[2])
    circuits = ["qc2", "qc3"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    out = QP_program.execute(circuits, backend=backend, shots=shots,
    seed=88)
    results2 = out.get_counts("qc2")
    results3 = out.get_counts("qc3")
    SDKLogger.logInfo(results3)
    XCTAssertEqual(results2, {"000": 518, "111": 506})
    XCTAssertEqual(results3, {"001": 119, "111": 129, "110": 134,
    "100": 117, "000": 129, "101": 126,
    "010": 145, "011": 125})

    }

    func test_local_qasm_simulator_one_shot() {
    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc3 = QP_program.create_circuit("qc3", [qr], [cr])
    qc2.h(qr[0])
    qc3.h(qr[0])
    qc3.cx(qr[0], qr[1])
    qc3.cx(qr[0], qr[2])
    circuits = ["qc2", "qc3"]
    backend = "local_qasm_simulator"  // the backend to run on
    shots = 1  // the number of shots in the experiment.
    result = QP_program.execute(circuits, backend=backend, shots=shots,
    seed=9)
    quantum_state = np.array([0.70710678+0.j, 0.70710678+0.j,
    0.00000000+0.j, 0.00000000+0.j,
    0.00000000+0.j, 0.00000000+0.j,
    0.00000000+0.j, 0.00000000+0.j])
    norm = np.dot(np.conj(quantum_state),
    result.get_data("qc2")["quantum_state"])
    self.assertAlmostEqual(norm, 1)
    quantum_state = np.array([0.70710678+0.j, 0+0.j,
    0.00000000+0.j, 0.00000000+0.j,
    0.00000000+0.j, 0.00000000+0.j,
    0.00000000+0.j, 0.70710678+0.j])
    norm = np.dot(np.conj(quantum_state),
    result.get_data("qc3")["quantum_state"])
    self.assertAlmostEqual(norm, 1)

    }

    func test_local_unitary_simulator() {
    let QP_program = try QuantumProgram()
    q = QP_program.create_quantum_register("q", 2)
    c = QP_program.create_classical_register("c", 2)
    qc1 = QP_program.create_circuit("qc1", [q], [c])
    qc2 = QP_program.create_circuit("qc2", [q], [c])
    qc1.h(q)
    qc2.cx(q[0], q[1])
    circuits = ["qc1", "qc2"]
    backend = "local_unitary_simulator"  // the backend to run on
    result = QP_program.execute(circuits, backend=backend)
    unitary1 = result.get_data("qc1")["unitary"]
    unitary2 = result.get_data("qc2")["unitary"]
    unitaryreal1 = np.array([[0.5, 0.5, 0.5, 0.5], [0.5, -0.5, 0.5, -0.5],
    [0.5, 0.5, -0.5, -0.5],
    [0.5, -0.5, -0.5, 0.5]])
    unitaryreal2 = np.array([[1,  0,  0, 0], [0, 0,  0,  1],
    [0.,  0, 1, 0], [0,  1,  0,  0]])
    norm1 = np.trace(np.dot(np.transpose(np.conj(unitaryreal1)), unitary1))
    norm2 = np.trace(np.dot(np.transpose(np.conj(unitaryreal2)), unitary2))
    self.assertAlmostEqual(norm1, 4)
    self.assertAlmostEqual(norm2, 4)

    }

    func test_run_program_map() {
    let QP_program = try QuantumProgram()
    backend = "local_qasm_simulator"  // the backend to run on
    shots = 100  // the number of shots in the experiment.
    max_credits = 3
    coupling_map = {0: [1], 1: [2], 2: [3], 3: [4]}
    initial_layout = [("q", 0): ("q", 0), ("q", 1): ("q", 1),
    ("q", 2): ("q", 2), ("q", 3): ("q", 3),
    ("q", 4): ("q", 4)]
    QP_program.load_qasm_file(self.QASM_FILE_PATH_2, name="circuit-dev")
    circuits = ["circuit-dev"]
    qobj = QP_program.compile(circuits, backend=backend, shots=shots,
    max_credits=max_credits, seed=65,
    coupling_map=coupling_map,
    initial_layout=initial_layout)
    result = QP_program.run(qobj)
    XCTAssertEqual(result.get_counts("circuit-dev"), {"10010": 100})

    }

    func test_execute_program_map() {
    let QP_program = try QuantumProgram()
    backend = "local_qasm_simulator"  // the backend to run on
    shots = 100  // the number of shots in the experiment.
    max_credits = 3
    coupling_map = [0: [1], 1: [2], 2: [3], 3: [4]]
    initial_layout = [("q", 0): ("q", 0), ("q", 1): ("q", 1),
    ("q", 2): ("q", 2), ("q", 3): ("q", 3),
    ("q", 4): ("q", 4)]
    QP_program.load_qasm_file(self.QASM_FILE_PATH_2, "circuit-dev")
    circuits = ["circuit-dev"]
    result = QP_program.execute(circuits, backend=backend, shots=shots,
    max_credits=max_credits,
    coupling_map=coupling_map,
    initial_layout=initial_layout, seed=5455)
    XCTAssertEqual(result.get_counts("circuit-dev"), ["10010": 100])

    }

    func test_average_data() {
    let QP_program = try QuantumProgram()
    q = QP_program.create_quantum_register("q", 2)
    c = QP_program.create_classical_register("c", 2)
    qc = QP_program.create_circuit("qc", [q], [c])
    qc.h(q[0])
    qc.cx(q[0], q[1])
    qc.measure(q[0], c[0])
    qc.measure(q[1], c[1])
    circuits = ["qc"]
    shots = 10000  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    results = QP_program.execute(circuits, backend=backend, shots=shots)
    observable = ["00": 1, "11": 1, "01": -1, "10": -1]
    meanzz = results.average_data("qc", observable)
    observable = ["00": 1, "11": -1, "01": 1, "10": -1]
    meanzi = results.average_data("qc", observable)
    observable = ["00": 1, "11": -1, "01": -1, "10": 1]
    meaniz = results.average_data("qc", observable)
    self.assertAlmostEqual(meanzz,  1, places=1)
    self.assertAlmostEqual(meanzi,  0, places=1)
    self.assertAlmostEqual(meaniz,  0, places=1)

    }

    func test_execute_one_circuit_simulator_online() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("q", 1)
    cr = QP_program.create_classical_register("c", 1)
    qc = QP_program.create_circuit("qc", [qr], [cr])
    qc.h(qr[0])
    qc.measure(qr[0], cr[0])
    shots = 1024  // the number of shots in the experiment.
    QP_program.set_api(token:token, url:QE_URL)
    backend = QP_program.online_simulators()[0]
    # print(backend)
    result = QP_program.execute(["qc"], backend=backend,
    shots=shots, max_credits=3,
    seed=73846087)
    counts = result.get_counts("qc")
    XCTAssertEqual(counts, ["0": 498, "1": 526])
    }

    func test_simulator_online_size() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("q", 25)
    cr = QP_program.create_classical_register("c", 25)
    qc = QP_program.create_circuit("qc", [qr], [cr])
    qc.h(qr)
    qc.measure(qr, cr)
    shots = 1  // the number of shots in the experiment.
    QP_program.set_api(token:token, url:QE_URL)
    backend = "ibmqx_qasm_simulator"
    result = QP_program.execute(["qc"], backend=backend,
                                shots=shots, max_credits=3,
                                seed=73846087)
    self.assertRaises(RegisterSizeError, result.get_data, "qc")
    }

    func test_execute_several_circuits_simulator_online() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("q", 2)
    cr = QP_program.create_classical_register("c", 2)
    qc1 = QP_program.create_circuit("qc1", [qr], [cr])
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc1.h(qr)
    qc2.h(qr[0])
    qc2.cx(qr[0], qr[1])
    qc1.measure(qr[0], cr[0])
    qc1.measure(qr[1], cr[1])
    qc2.measure(qr[0], cr[0])
    qc2.measure(qr[1], cr[1])
    circuits = ["qc1", "qc2"]
    shots = 1024  // the number of shots in the experiment.
    QP_program.set_api(token:token, url:QE_URL)
    backend = QP_program.online_simulators()[0]
    result = QP_program.execute(circuits, backend=backend, shots=shots,
    max_credits=3, seed=1287126141)
    counts1 = result.get_counts("qc1")
    counts2 = result.get_counts("qc2")
    XCTAssertEqual(counts1,  ["10": 277, "11": 238, "01": 258, "00": 251])
    XCTAssertEqual(counts2, ["11": 515, "00": 509])
    }

    func test_execute_one_circuit_real_online() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("qr", 1)
    cr = QP_program.create_classical_register("cr", 1)
    qc = QP_program.create_circuit("circuitName", [qr], [cr])
    qc.h(qr)
    qc.measure(qr[0], cr[0])
    QP_program.set_api(token:token, url:QE_URL)
    backend = "ibmqx_qasm_simulator"
    shots = 1  // the number of shots in the experiment.
    status = QP_program.get_backend_status(backend)
    if status["available"] is False:
    pass
    else:
    result = QP_program.execute(["circuitName"], backend=backend,
    shots=shots, max_credits=3)
    SDKLogger.logInfo(result)

    }

    func test_local_qasm_simulator_two_registers() {
    let QP_program = try QuantumProgram()
    q1 = QP_program.create_quantum_register("q1", 2)
    c1 = QP_program.create_classical_register("c1", 2)
    q2 = QP_program.create_quantum_register("q2", 2)
    c2 = QP_program.create_classical_register("c2", 2)
    qc1 = QP_program.create_circuit("qc1", [q1, q2], [c1, c2])
    qc2 = QP_program.create_circuit("qc2", [q1, q2], [c1, c2])

    qc1.x(q1[0])
    qc2.x(q2[1])
    qc1.measure(q1[0], c1[0])
    qc1.measure(q1[1], c1[1])
    qc1.measure(q2[0], c2[0])
    qc1.measure(q2[1], c2[1])
    qc2.measure(q1[0], c1[0])
    qc2.measure(q1[1], c1[1])
    qc2.measure(q2[0], c2[0])
    qc2.measure(q2[1], c2[1])
    circuits = ["qc1", "qc2"]
    shots = 1024  // the number of shots in the experiment.
    backend = "local_qasm_simulator"
    result = QP_program.execute(circuits, backend=backend, shots=shots,
    seed=8458)
    result1 = result.get_counts("qc1")
    result2 = result.get_counts("qc2")
    XCTAssertEqual(result1, {"00 01": 1024})
    XCTAssertEqual(result2, {"10 00": 1024})

    }

    func test_online_qasm_simulator_two_registers() {
    let QP_program = try QuantumProgram()
    q1 = QP_program.create_quantum_register("q1", 2)
    c1 = QP_program.create_classical_register("c1", 2)
    q2 = QP_program.create_quantum_register("q2", 2)
    c2 = QP_program.create_classical_register("c2", 2)
    qc1 = QP_program.create_circuit("qc1", [q1, q2], [c1, c2])
    qc2 = QP_program.create_circuit("qc2", [q1, q2], [c1, c2])

    qc1.x(q1[0])
    qc2.x(q2[1])
    qc1.measure(q1[0], c1[0])
    qc1.measure(q1[1], c1[1])
    qc1.measure(q2[0], c2[0])
    qc1.measure(q2[1], c2[1])
    qc2.measure(q1[0], c1[0])
    qc2.measure(q1[1], c1[1])
    qc2.measure(q2[0], c2[0])
    qc2.measure(q2[1], c2[1])
    circuits = ["qc1", "qc2"]
    shots = 1024  # the number of shots in the experiment.
    QP_program.set_api(token:token, url:QE_URL)
    backend = QP_program.online_simulators()[0]
    result = QP_program.execute(circuits, backend=backend, shots=shots,
    seed=8458)
    result1 = result.get_counts("qc1")
    result2 = result.get_counts("qc2")
    XCTAssertEqual(result1, {"00 01": 1024})
    XCTAssertEqual(result2, {"10 00": 1024})
    }

    //###############################################################
    //# More test cases for interesting examples
    //###############################################################

    func test_add_circuit() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("qr", 2)
    cr = QP_program.create_classical_register("cr", 2)
    qc1 = QP_program.create_circuit("qc1", [qr], [cr])
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc1.h(qr[0])
    qc1.measure(qr[0], cr[0])
    qc2.measure(qr[1], cr[1])
    new_circuit = qc1 + qc2
    QP_program.add_circuit("new_circuit", new_circuit)
    // new_circuit.measure(qr[0], cr[0])
    circuits = ["new_circuit"]
    backend = "local_qasm_simulator"  # the backend to run on
    shots = 1024  # the number of shots in the experiment.
    result = QP_program.execute(circuits, backend=backend, shots=shots,
    seed=78)
    // print(QP_program.get_qasm("new_circuit"))
    XCTAssertEqual(result.get_counts("new_circuit"),["00": 505, "01": 519])

    }

    func test_add_circuit_fail() {
    let QP_program = try QuantumProgram()
    qr = QP_program.create_quantum_register("qr", 1)
    cr = QP_program.create_classical_register("cr", 1)
    q = QP_program.create_quantum_register("q", 1)
    c = QP_program.create_classical_register("c", 1)
    qc1 = QP_program.create_circuit("qc1", [qr], [cr])
    qc2 = QP_program.create_circuit("qc2", [q], [c])
    qc1.h(qr[0])
    qc1.measure(qr[0], cr[0])
    qc2.measure(q[0], c[0])
    // new_circuit = qc1 + qc2
    self.assertRaises(QISKitError, qc1.__add__, qc2)

    }

    func test_example_multiple_compile() {
    coupling_map = {0: [1, 2],
    1: [2],
    2: [],
    3: [2, 4],
    4: [2]}
    QPS_SPECS = {
    "circuits": [{
    "name": "ghz",
    "quantum_registers": [{
    "name": "q",
    "size": 5
    }],
    "classical_registers": [{
    "name": "c",
    "size": 5}
    ]}, {
    "name": "bell",
    "quantum_registers": [{
    "name": "q",
    "size": 5
    }],
    "classical_registers": [{
    "name": "c",
    "size": 5
    }]}
    ]
    }
    qp = QuantumProgram(specs: QPS_SPECS)
    ghz = qp.get_circuit("ghz")
    bell = qp.get_circuit("bell")
    q = qp.get_quantum_register("q")
    c = qp.get_classical_register("c")
    # Create a GHZ state
    ghz.h(q[0])
    for i in range(4):
    ghz.cx(q[i], q[i+1])
    // Insert a barrier before measurement
    ghz.barrier()
    // Measure all of the qubits in the standard basis
    for i in range(5):
    ghz.measure(q[i], c[i])
    // Create a Bell state
    bell.h(q[0])
    bell.cx(q[0], q[1])
    bell.barrier()
    bell.measure(q[0], c[0])
    bell.measure(q[1], c[1])
    bellobj = qp.compile(["bell"], backend="local_qasm_simulator",
    shots=2048, seed=10)
    ghzobj = qp.compile(["ghz"], backend="local_qasm_simulator",
    shots=2048, coupling_map=coupling_map,
    seed=10)
    bellresult = qp.run(bellobj)
    ghzresult = qp.run(ghzobj)
    SDKLogger.logInfo(bellresult.get_counts("bell"))
    SDKLogger.logInfo(ghzresult.get_counts("ghz"))
    XCTAssertEqual(bellresult.get_counts("bell"),
    {"00000": 1034, "00011": 1014})
    XCTAssertEqual(ghzresult.get_counts("ghz"),
    {"00000": 1047, "11111": 1001})

    }

    func test_example_swap_bits() {
    backend = "ibmqx_qasm_simulator"
    coupling_map = {0: [1, 8], 1: [2, 9], 2: [3, 10], 3: [4, 11],
    4: [5, 12], 5: [6, 13], 6: [7, 14], 7: [15], 8: [9],
    9: [10], 10: [11], 11: [12], 12: [13], 13: [14],
    14: [15]}

    }

    func swap(qc, q0, q1):
    qc.cx(q0, q1)
    qc.cx(q1, q0)
    qc.cx(q0, q1)
    n = 3  # make this at least 3
    QPS_SPECS = {
    "circuits": [{
    "name": "swapping",
    "quantum_registers": [{
    "name": "q",
    "size": n},
    {"name": "r",
    "size": n}
    ],
    "classical_registers": [
    {"name": "ans",
    "size": 2*n},
    ]
    }]
    }
    qp = QuantumProgram(specs: QPS_SPECS)
    qp.set_api(token:token, url:QE_URL)
    if backend not in qp.online_simulators():
    unittest.skip("backend "{}" not available".format(backend))
    qc = qp.get_circuit("swapping")
    q = qp.get_quantum_register("q")
    r = qp.get_quantum_register("r")
    ans = qp.get_classical_register("ans")
    # Set the first bit of q
    qc.x(q[0])
    # Swap the set bit
    swap(qc, q[0], q[n-1])
    swap(qc, q[n-1], r[n-1])
    swap(qc, r[n-1], q[1])
    swap(qc, q[1], r[1])
    # Insert a barrier before measurement
    qc.barrier()
    # Measure all of the qubits in the standard basis
    for j in range(n):
    qc.measure(q[j], ans[j])
    qc.measure(r[j], ans[j+n])
    # First version: no mapping
    result = qp.execute(["swapping"], backend=backend,
    coupling_map=None, shots=1024,
    seed=14)
    XCTAssertEqual(result.get_counts("swapping"),
    {"010000": 1024})
    # Second version: map to coupling graph
    result = qp.execute(["swapping"], backend=backend,
    coupling_map=coupling_map, shots=1024,
    seed=14)
    XCTAssertEqual(result.get_counts("swapping"),
    {"010000": 1024})

    } func test_offline() {
    import string
    import random
    qp = QuantumProgram()
    FAKE_TOKEN = "thistokenisnotgoingtobesentnowhere"
    FAKE_URL = "http://{0}.com".format(
    "".join(random.choice(string.ascii_lowercase) for _ in range(63))
    )
    # SDK will throw ConnectionError on every call that implies a connection
    self.assertRaises(ConnectionError, qp.set_api, FAKE_TOKEN, FAKE_URL)

    } func test_results_save_load() {
    """Test saving and loading the results of a circuit.

    Test for the "local_unitary_simulator" and "local_qasm_simulator"
    """
    let QP_program = try QuantumProgram()
    metadata = {"testval":5}
    q = QP_program.create_quantum_register("q", 2)
    c = QP_program.create_classical_register("c", 2)
    qc1 = QP_program.create_circuit("qc1", [q], [c])
    qc2 = QP_program.create_circuit("qc2", [q], [c])
    qc1.h(q)
    qc2.cx(q[0], q[1])
    circuits = ["qc1", "qc2"]

    result1 = QP_program.execute(circuits, backend="local_unitary_simulator")
    result2 = QP_program.execute(circuits, backend="local_qasm_simulator")

    test_1_path = self._get_resource_path("test_save_load1.json")
    test_2_path = self._get_resource_path("test_save_load2.json")

    #delete these files if they exist
    if os.path.exists(test_1_path):
    os.remove(test_1_path)

    if os.path.exists(test_2_path):
    os.remove(test_2_path)

    file1 = file_io.save_result_to_file(result1, test_1_path, metadata=metadata)
    file2 = file_io.save_result_to_file(result2, test_2_path, metadata=metadata)

    result_loaded1, metadata_loaded1 = file_io.load_result_from_file(file1)
    result_loaded2, metadata_loaded2 = file_io.load_result_from_file(file1)

    self.assertAlmostEqual(metadata_loaded1["testval"], 5)
    self.assertAlmostEqual(metadata_loaded2["testval"], 5)

    #remove files to keep directory clean
    os.remove(file1)
    os.remove(file2)

    } func test_qubitpol() {

    """Test the results of the qubitpol function in Results. Do two 2Q circuits
    in the first do nothing and in the second do X on the first qubit.
    """
    let QP_program = try QuantumProgram()
    q = QP_program.create_quantum_register("q", 2)
    c = QP_program.create_classical_register("c", 2)
    qc1 = QP_program.create_circuit("qc1", [q], [c])
    qc2 = QP_program.create_circuit("qc2", [q], [c])
    qc2.x(q[0])
    qc1.measure(q, c)
    qc2.measure(q, c)
    circuits = ["qc1", "qc2"]
    xvals_dict = {circuits[0]: 0, circuits[1]: 1}

    result = QP_program.execute(circuits, backend="local_qasm_simulator")

    yvals, xvals = result.get_qubitpol_vs_xval(xvals_dict=xvals_dict)

    self.assertTrue(np.array_equal(yvals, [[-1,-1],[1,-1]]))
    self.assertTrue(np.array_equal(xvals, [0,1]))

    } func test_reconfig() {
    """Test reconfiguring the qobj from 1024 shots to 2048 using
    reconfig instead of recompile
    """
    let QP_program = try QuantumProgram(specs: self.QPS_SPECS)
    qr = QP_program.get_quantum_register("qname")
    cr = QP_program.get_classical_register("cname")
    qc2 = QP_program.create_circuit("qc2", [qr], [cr])
    qc2.measure(qr[0], cr[0])
    qc2.measure(qr[1], cr[1])
    qc2.measure(qr[2], cr[2])
    shots = 1024  # the number of shots in the experiment.
    backend = "local_qasm_simulator"
    test_config = {"0": 0, "1": 1}
    qobj = QP_program.compile(["qc2"], backend=backend, shots=shots, config=test_config)
    out = QP_program.run(qobj)
    results = out.get_counts("qc2")

    #change the number of shots and re-run to test if the reconfig does not break
    #the ability to run the qobj
    qobj = QP_program.reconfig(qobj, shots=2048)
    out2 = QP_program.run(qobj)
    results2 = out2.get_counts("qc2")

    XCTAssertEqual(results, {"000": 1024})
    XCTAssertEqual(results2, {"000": 2048})

    #change backend
    qobj = QP_program.reconfig(qobj, backend="local_unitary_simulator")
    XCTAssertEqual(qobj["config"]["backend"], "local_unitary_simulator")
    #change maxcredits
    qobj = QP_program.reconfig(qobj, max_credits=11)
    XCTAssertEqual(qobj["config"]["max_credits"], 11)
    #change seed
    qobj = QP_program.reconfig(qobj, seed=11)
    XCTAssertEqual(qobj["circuits"][0]["seed"], 11)
    #change the config
    test_config_2 = {"0": 2}
    qobj = QP_program.reconfig(qobj, config=test_config_2)
    XCTAssertEqual(qobj["circuits"][0]["config"]["0"], 2)
    XCTAssertEqual(qobj["circuits"][0]["config"]["1"], 1)
    }
*/
}
