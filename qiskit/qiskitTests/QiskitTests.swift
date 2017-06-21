//
//  QiskitTests.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
import qiskit

class QiskitTests: XCTestCase {
    
    // enter your token in your test schema environment variable "QUANTUM_TOKEN"
    static private var APItoken = ""
    static private let TESTURL = "https://quantumexperience.ng.bluemix.net/api/"
    
    override class func setUp() {
        let environment = ProcessInfo.processInfo.environment
        if let token = environment["QUANTUM_TOKEN"] {
            QiskitTests.APItoken = token
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test5Qubit() {
        do {
            let str: String =
                "OPENQASM 2.0;\n" +
                    "include \"qelib1.inc\";\n" +
                    "qreg q[5];\n" +
                    "creg c[5];\n" +
                    "x q[0];\n" +
                    "x q[1];\n" +
                    "h q[2];\n" +
                    "measure q[0] -> c[0];\n" +
                    "measure q[1] -> c[1];\n" +
                    "measure q[2] -> c[2];\n" +
                    "measure q[3] -> c[3];\n" +
            "measure q[4] -> c[4];"
            let q = try QuantumRegister("q", 5)
            let c = try ClassicalRegister("c", 5)
            let circuit = try QuantumCircuit([q,c])
            _ = try circuit.x(q[0])
            _ = try circuit.x(q[1])
            _ = try circuit.h(q[2])
            _ = try circuit.measure(q[0], c[0])
            _ = try circuit.measure(q[1], c[1])
            _ = try circuit.measure(q[2], c[2])
            _ = try circuit.measure(q[3], c[3])
            _ = try circuit.measure(q[4], c[4])

            XCTAssertEqual(str, circuit.qasm())
            //try self.runJob(circuit,"simulator")
        } catch let error {
            XCTFail("\(error)")
        }
    }

    func testMakeBell1() {
        do {
            let str: String =
                "OPENQASM 2.0;\n" +
                    "include \"qelib1.inc\";\n" +
                    "qreg q[3];\n" +
                    "creg c[2];\n" +
                    "h q[0];\n" +
                    "cx q[0],q[2];\n" +
                    "measure q[0] -> c[0];\n" +
            "measure q[2] -> c[1];"

            let q = try QuantumRegister("q", 3)
            let c = try ClassicalRegister("c", 2)
            let circuit = try QuantumCircuit([q,c])
            _ = try circuit.h(q[0])
            _ = try circuit.cx(q[0], q[2])
            _ = try circuit.measure(q[0], c[0])
            _ = try circuit.measure(q[2], c[1])

            XCTAssertEqual(str, circuit.qasm())
        } catch let error {
            XCTFail("\(error)")
        }
    }

    /**
     Majority gate.
     */
    private class func majority(_ p: QuantumCircuit, _ a: QuantumRegisterTuple, _ b:QuantumRegisterTuple, _ c:QuantumRegisterTuple) throws {
        _ = try p.cx(c, b)
        _ = try p.cx(c, a)
        _ = try p.ccx(a, b, c)
    }

    /**
     Majority gate.
     */
    private class func unmajority(_ p: QuantumCircuit, _ a: QuantumRegisterTuple, _ b:QuantumRegisterTuple, _ c:QuantumRegisterTuple) throws {
        _ = try p.ccx(a, b, c)
        _ = try p.cx(c, a)
        _ = try p.cx(a, b)
    }

    func testRippleCarryAdder() {
        do {
            let str: String =
                "OPENQASM 2.0;\n" +
                    "include \"qelib1.inc\";\n" +
                    "qreg cin[1];\n" +
                    "qreg a[4];\n" +
                    "qreg b[4];\n" +
                    "qreg cout[1];\n" +
                    "creg ans[5];\n" +
                    "x a[0];\n" +
                    "x b[0];\n" +
                    "x b[1];\n" +
                    "x b[2];\n" +
                    "x b[3];\n" +
                    "cx a[0],b[0];\n" +
                    "cx a[0],cin[0];\n" +
                    "ccx cin[0],b[0],a[0];\n" +
                    "cx a[1],b[1];\n" +
                    "cx a[1],a[0];\n" +
                    "ccx a[0],b[1],a[1];\n" +
                    "cx a[2],b[2];\n" +
                    "cx a[2],a[1];\n" +
                    "ccx a[1],b[2],a[2];\n" +
                    "cx a[3],b[3];\n" +
                    "cx a[3],a[2];\n" +
                    "ccx a[2],b[3],a[3];\n" +
                    "cx a[3],cout[0];\n" +
                    "ccx a[2],b[3],a[3];\n" +
                    "cx a[3],a[2];\n" +
                    "cx a[2],b[3];\n" +
                    "ccx a[1],b[2],a[2];\n" +
                    "cx a[2],a[1];\n" +
                    "cx a[1],b[2];\n" +
                    "ccx a[0],b[1],a[1];\n" +
                    "cx a[1],a[0];\n" +
                    "cx a[0],b[1];\n" +
                    "ccx cin[0],b[0],a[0];\n" +
                    "cx a[0],cin[0];\n" +
                    "cx cin[0],b[0];\n" +
                    "measure b[0] -> ans[0];\n" +
                    "measure b[1] -> ans[1];\n" +
                    "measure b[2] -> ans[2];\n" +
                    "measure b[3] -> ans[3];\n" +
                    "measure cout[0] -> ans[4];"

            let cin = try QuantumRegister("cin", 1)
            let a = try QuantumRegister("a", 4)
            let b = try QuantumRegister("b", 4)
            let cout = try QuantumRegister("cout", 1)
            let ans = try ClassicalRegister("ans", 5)
            let circuit = try QuantumCircuit([cin,a,b,cout,ans])
            _ = try circuit.x(a[0])
            _ = try circuit.x(b)
            try QiskitTests.majority(circuit, cin[0], b[0], a[0])
            for j in 0..<3 {
                try QiskitTests.majority(circuit, a[j], b[j + 1], a[j + 1])
            }
            _ = try circuit.cx(a[3], cout[0])
            for j in (0..<3).reversed() {
                try QiskitTests.unmajority(circuit, a[j], b[j + 1], a[j + 1])
            }
            try QiskitTests.unmajority(circuit, cin[0], b[0], a[0])
            for j in 0..<4 {
                _ = try circuit.measure(b[j], ans[j])  // Measure the output register
            }
            _ = try circuit.measure(cout[0], ans[4])

            XCTAssertEqual(str, circuit.qasm())
            //try self.runJob(circuit,"simulator")
         } catch let error {
            XCTFail("\(error)")
         }
    }

    func testQFTAndMeasure2() {
        do {
            let piDiv2: Double = Double.pi / 2.0
            let piDiv2S = String(format:"%.15f",piDiv2)
            let piDiv4: Double = Double.pi / 4.0
            let piDiv4S = String(format:"%.15f",piDiv4)
            let piDiv8: Double = Double.pi / 8.0
            let piDiv8S = String(format:"%.15f",piDiv8)
            let str: String =
                "OPENQASM 2.0;\n" +
                    "include \"qelib1.inc\";\n" +
                    "qreg q[4];\n" +
                    "creg c0[1];\n" +
                    "creg c1[1];\n" +
                    "creg c2[1];\n" +
                    "creg c3[1];\n" +
                    "h q[0];\n" +
                    "h q[1];\n" +
                    "h q[2];\n" +
                    "h q[3];\n" +
                    "barrier q[0],q[1],q[2],q[3];\n" +
                    "h q[0];\n" +
                    "measure q[0] -> c0[0];\n" +
                    "if(c0==1) u1(\(piDiv2S)) q[1];\n" +
                    "h q[1];\n" +
                    "measure q[1] -> c1[0];\n" +
                    "if(c0==1) u1(\(piDiv4S)) q[2];\n" +
                    "if(c1==1) u1(\(piDiv2S)) q[2];\n" +
                    "h q[2];\n" +
                    "measure q[2] -> c2[0];\n" +
                    "if(c0==1) u1(\(piDiv8S)) q[3];\n" +
                    "if(c1==1) u1(\(piDiv4S)) q[3];\n" +
                    "if(c2==1) u1(\(piDiv2S)) q[3];\n" +
                    "h q[3];\n" +
                    "measure q[3] -> c3[0];"

            let q = try QuantumRegister("q", 4)
            let c0 = try ClassicalRegister("c0", 1)
            let c1 = try ClassicalRegister("c1", 1)
            let c2 = try ClassicalRegister("c2", 1)
            let c3 = try ClassicalRegister("c3", 1)
            let circuit = try QuantumCircuit([q,c0,c1,c2,c3])
            _ = try circuit.h(q)
            _ = try circuit.barrier([q])
            _ = try circuit.h(q[0])
            _ = try circuit.measure(q[0], c0[0])
            _ = try circuit.u1(piDiv2, q[1]).c_if(c0, 1)
            _ = try circuit.h(q[1])
            _ = try circuit.measure(q[1], c1[0])
            _ = try circuit.u1(piDiv4, q[2]).c_if(c0, 1)
            _ = try circuit.u1(piDiv2, q[2]).c_if(c1, 1)
            _ = try circuit.h(q[2])
            _ = try circuit.measure(q[2], c2[0])
            _ = try circuit.u1(piDiv8, q[3]).c_if(c0, 1)
            _ = try circuit.u1(piDiv4, q[3]).c_if(c1, 1)
            _ = try circuit.u1(piDiv2, q[3]).c_if(c2, 1)
            _ = try circuit.h(q[3])
            _ = try circuit.measure(q[3], c3[0])

            XCTAssertEqual(str, circuit.qasm())
            //try self.runJob(circuit,"simulator")
         } catch let error {
            XCTFail("\(error)")
         }
    }

    func test4developers() {
        do {
            let str: String =
            "OPENQASM 2.0;\n" +
            "include \"qelib1.inc\";\n" +
            "qreg qr[4];\n" +
            "creg cr[4];\n" +
            "h qr[0];\n" +
            "x qr[1];\n" +
            "y qr[2];\n" +
            "z qr[3];\n" +
            "cx qr[0],qr[2];\n" +
            "barrier qr[0],qr[1],qr[2],qr[3];\n" +
            "u1(0.300000000000000) qr[0];\n" +
            "u2(0.300000000000000,0.200000000000000) qr[1];\n" +
            "u3(0.300000000000000,0.200000000000000,0.100000000000000) qr[2];\n" +
            "s qr[0];\n" +
            "t qr[1];\n" +
            "id qr[1];\n" +
            "measure qr[0] -> cr[0];"

            let Q_program = try QuantumProgram()
            _ = try Q_program.create_quantum_registers("qr", 4)
            _ = try Q_program.create_classical_registers("cr", 4)
            _ = try Q_program.create_circuit("Circuit", ["qr"], ["cr"])
            guard let circuit = Q_program.get_circuit("Circuit") else {
                XCTFail("Missing circuit")
                return
            }
            guard let quantum_r = Q_program.get_quantum_registers("qr") else {
                XCTFail("Missing quantum register")
                return
            }
            guard let classical_r = Q_program.get_classical_registers("cr") else {
                XCTFail("Missing classical register")
                return
            }

            // H (Hadamard) gate to the qubit 0 in the Quantum Register "qr"
            _ = try circuit.h(quantum_r[0])

            // Pauli X gate to the qubit 1 in the Quantum Register "qr"
            _ = try circuit.x(quantum_r[1])

            // Pauli Y gate to the qubit 2 in the Quantum Register "qr"
            _ = try circuit.y(quantum_r[2])

            // Pauli Z gate to the qubit 3 in the Quantum Register "qr"
            _ = try circuit.z(quantum_r[3])

            // CNOT (Controlled-NOT) gate from qubit 0 to the Qbit 2
            _ = try circuit.cx(quantum_r[0], quantum_r[2])

            // add a barrier to your circuit
            _ = try circuit.barrier()

            // first physical gate: u1(lambda) to qubit 0
            _ = try circuit.u1(0.3, quantum_r[0])

            // second physical gate: u2(phi,lambda) to qubit 1
            _ = try circuit.u2(0.3, 0.2, quantum_r[1])

            // second physical gate: u3(theta,phi,lambda) to qubit 2
            _ = try circuit.u3(0.3, 0.2, 0.1, quantum_r[2])

            // S Phase gate to qubit 0
            _ = try circuit.s(quantum_r[0])

            // T Phase gate to qubit 1
            _ = try circuit.t(quantum_r[1])

            // identity gate to qubit 1
            _ = try circuit.iden(quantum_r[1])

            // Note: "if" is not implemented in the local simulator right now,
            //       so we comment it out here. You can uncomment it and
            //       run in the online simulator if you'd like.

            // Classical if, from qubit2 gate Z to classical bit 1
            // circuit.z(quantum_r[2]).c_if(classical_r, 0)
            
            // measure gate from the qubit 0 to classical bit 0
            _ = try circuit.measure(quantum_r[0], classical_r[0])
            
            let QASM_source = try Q_program.get_qasm("Circuit")

            XCTAssertEqual(str, QASM_source)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    private func runJob(_ qConfig: Qconfig, _ circuit: QuantumCircuit, _ device: String) throws {
        let qp = try QuantumProgram()
        _ = qp.add_circuit("circuit",circuit)
        try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

        let asyncExpectation = self.expectation(description: "runJob")
        qp.execute(["circuit"], device: device) { (result, error) in
            if error != nil {
                XCTFail("Failure in runJob: \(error!)")
                asyncExpectation.fulfill()
                return
            }
            print(result!)
            asyncExpectation.fulfill()
        }
        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in runJob")
        })
    }
}
