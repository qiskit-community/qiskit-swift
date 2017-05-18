//
//  QiskitTests.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
@testable import qiskit

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
                .append(XGate(q[0]))
                .append(XGate(q[1]))
                .append(HGate(q[2]))
                .append(Measure(q[0], c[0]))
                .append(Measure(q[1], c[1]))
                .append(Measure(q[2], c[2]))
                .append(Measure(q[3], c[3]))
                .append(Measure(q[4], c[4]))

            XCTAssertEqual(str, circuit.description)
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
            let circuit = try QuantumCircuit([q,c]).append(contentsOf:
                [HGate(q[0]),
                 CnotGate(q[0], q[2]),
                 Measure(q[0], c[0]),
                 Measure(q[2], c[1])])

            XCTAssertEqual(str, circuit.description)
            //try self.runJob(circuit,"simulator")
        } catch let error {
        XCTFail("\(error)")
        }
    }

    func testMakeBell2() {
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
            var circuit = try QuantumCircuit([q,c])
            circuit += HGate(q[0])
            circuit += CnotGate(q[0], q[2])
            circuit += Measure(q[0], c[0])
            circuit += Measure(q[2], c[1])

            XCTAssertEqual(str, circuit.description)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    /**
     Majority gate.
     */
    private class func majority(_ p: inout QuantumCircuit, _ a: QuantumRegisterTuple, _ b:QuantumRegisterTuple, _ c:QuantumRegisterTuple) {
        p += CnotGate(c, b)
        p += CnotGate(c, a)
        p += ToffoliGate(a, b, c)
    }

    /**
     Majority gate.
     */
    private class func unmajority(_ p: inout QuantumCircuit, _ a: QuantumRegisterTuple, _ b:QuantumRegisterTuple, _ c:QuantumRegisterTuple) throws {
        p += ToffoliGate(a, b, c)
        p += CnotGate(c, a)
        p += CnotGate(a, b)
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
                    "x b;\n" +
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
            var circuit = try QuantumCircuit([cin,a,b,cout,ans])
            circuit += XGate(a[0])
            circuit += XGate(b)
            QiskitTests.majority(&circuit, cin[0], b[0], a[0])
            for j in 0..<3 {
                QiskitTests.majority(&circuit, a[j], b[j + 1], a[j + 1])
            }
            circuit += CnotGate(a[3], cout[0])
            for j in (0..<3).reversed() {
                try QiskitTests.unmajority(&circuit, a[j], b[j + 1], a[j + 1])
            }
            try QiskitTests.unmajority(&circuit, cin[0], b[0], a[0])
            for j in 0..<4 {
                circuit += Measure(b[j], ans[j])  // Measure the output register
            }
            circuit += Measure(cout[0], ans[4])

            XCTAssertEqual(str, circuit.description)
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
                    "h q;\n" +
                    "barrier q;\n" +
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
            var circuit = try QuantumCircuit([q,c0,c1,c2,c3])
            circuit += HGate(q)
            circuit += Barrier(q)
            circuit += HGate(q[0])
            circuit += Measure(q[0], c0[0])
            circuit += try U1Gate(piDiv2, q[1]).c_if(c0, 1)
            circuit += HGate(q[1])
            circuit += Measure(q[1], c1[0])
            circuit += try U1Gate(piDiv4, q[2]).c_if(c0, 1)
            circuit += try U1Gate(piDiv2, q[2]).c_if(c1, 1)
            circuit += HGate(q[2])
            circuit += Measure(q[2], c2[0])
            circuit += try U1Gate(piDiv8, q[3]).c_if(c0, 1)
            circuit += try U1Gate(piDiv4, q[3]).c_if(c1, 1)
            circuit += try U1Gate(piDiv2, q[3]).c_if(c2, 1)
            circuit += HGate(q[3])
            circuit += Measure(q[3], c3[0])

            XCTAssertEqual(str, circuit.description)
            //try self.runJob(circuit,"simulator")
         } catch let error {
            XCTFail("\(error)")
         }
    }

    private func runJob(_ circuit: QuantumCircuit, _ backend: String) throws {
        var compile = QuantumProgram.QASMCompile()
        compile.backend = backend
        let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
        let program = QuantumProgram(config, compile, circuit)

        let asyncExpectation = self.expectation(description: "runJob")
        program.run { (result, error) in
            if error != nil {
                XCTFail("Failure in runJob: \(error!)")
                asyncExpectation.fulfill()
                return
            }
            guard let jobResult = result else {
                XCTFail("Missing qasms array")
                asyncExpectation.fulfill()
                return
            }
            guard let qasms = jobResult.qasms else {
                XCTFail("Missing qasms array")
                asyncExpectation.fulfill()
                return
            }
            if qasms.isEmpty {
                XCTFail("Empty qasms array")
                asyncExpectation.fulfill()
                return
            }
            let qasm = qasms[0]
            guard let result = qasm.result else {
                XCTFail("Missing qasm result")
                asyncExpectation.fulfill()
                return
            }
            guard let data = result.data else {
                XCTFail("Missing qasm result data")
                asyncExpectation.fulfill()
                return
            }
            guard let counts = data.counts else {
                XCTFail("Missing qasm result data counts")
                asyncExpectation.fulfill()
                return
            }
            print("Counts: \(counts)")
            guard let idExecution = qasm.executionId else {
                XCTFail("Missing qasm executionId")
                asyncExpectation.fulfill()
                return
            }
            program.getExecution(idExecution) { (execution, error) in
                if error != nil {
                    XCTFail("Failure in runJob: \(error!)")
                    asyncExpectation.fulfill()
                    return
                }
                print("Execution: \(execution!)")
                program.getResultFromExecution(idExecution) { (result, error) in
                    defer {
                        asyncExpectation.fulfill()
                    }
                    if error != nil {
                        XCTFail("Failure in runJob: \(error!)")
                        return
                    }
                    print("Result: \(result!)")
                }
            }
        }
        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in runJob")
        })
    }
}
