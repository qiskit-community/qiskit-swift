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
        let str: String =
            "OPENQASM 2.0;\n" +
                "// Simple 5 qubit test\n" +
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
        let q = QuantumRegister("q", 5)
        let c = ClassicalRegister("c", 5)
        let circuit = QuantumCircuit()
            .append(Comment("Simple 5 qubit test"))
            .append(Include("qelib1.inc"))
            .append(q)
            .append(c)
            .append(Gate("x", [], [q[0]]))
            .append(Gate("x", [], [q[1]]))
            .append(Gate("h", [], [q[2]]))
            .append(Measure(q[0], c[0]))
            .append(Measure(q[1], c[1]))
            .append(Measure(q[2], c[2]))
            .append(Measure(q[3], c[3]))
            .append(Measure(q[4], c[4]))
        print(circuit.description)
        XCTAssertEqual(str, circuit.description)
        /*
         do {
            var compile = QuantumProgram.QASMCompile()
            compile.backend = "simulator"
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            self.runJob(QuantumProgram(config, compile, circuit))
         } catch let error {
            XCTFail("\(error)")
         }
         */
    }

    func testMakeBell1() {
        let str: String =
            "OPENQASM 2.0;\n" +
                "// Make Bell\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
        "measure q[2] -> c[1];"

        let q = QuantumRegister("q", 3)
        let c = ClassicalRegister("c", 2)
        let circuit = QuantumCircuit().append(contentsOf:
            [Comment("Make Bell"),
             Include("qelib1.inc"),
             q,
             c,
             Gate("h", [], [q[0]]),
             QCX(q[0], q[2]),
             Measure(q[0], c[0]),
             Measure(q[2], c[1])])
        print(circuit.description)
        XCTAssertEqual(str, circuit.description)
/*
         do {
            var compile = QuantumProgram.QASMCompile()
            compile.backend = "simulator"
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            self.runJob(QuantumProgram(config, compile, circuit))
         } catch let error {
            XCTFail("\(error)")
         }
*/
    }

    func testMakeBell2() {
        let str: String =
            "OPENQASM 2.0;\n" +
                "// Make Bell\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
        "measure q[2] -> c[1];"

        let q = QuantumRegister("q", 3)
        let c = ClassicalRegister("c", 2)
        let circuit = QuantumCircuit()
            + Comment("Make Bell")
            + Include("qelib1.inc")
            + q
            + c
            + Gate("h", [], [q[0]])
            + QCX(q[0], q[2])
            + Measure(q[0], c[0])
            + Measure(q[2], c[1])
        print(circuit.description)
        XCTAssertEqual(str, circuit.description)
        /*
         do {
            var compile = QuantumProgram.QASMCompile()
            compile.backend = "simulator"
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            self.runJob(QuantumProgram(config, compile, circuit))
        } catch let error {
            XCTFail("\(error)")
        }
         */
    }

    func testMakeBell3() {
        let str: String =
            "OPENQASM 2.0;\n" +
                "// Make Bell\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
        "measure q[2] -> c[1];"

        let q = QuantumRegister("q", 3)
        let c = ClassicalRegister("c", 2)
        var circuit = QuantumCircuit()
        circuit += Comment("Make Bell")
        circuit += Include("qelib1.inc")
        circuit += q
        circuit += c
        circuit += Gate("h", [], [q[0]])
        circuit += QCX(q[0], q[2])
        circuit += Measure(q[0], c[0])
        circuit += Measure(q[2], c[1])
        print(circuit.description)
        XCTAssertEqual(str, circuit.description)
    }

    func testRippleCarryAdder() {
        let str: String =
            "OPENQASM 2.0;\n" +
                "include \"qelib1.inc\";\n" +
                "gate majority a,b,c\n" +
                "{\n" +
                "  cx c,b;\n" +
                "  cx c,a;\n" +
                "  ccx a,b,c;\n" +
                "}\n" +
                "gate unmaj a,b,c\n" +
                "{\n" +
                "  ccx a,b,c;\n" +
                "  cx c,a;\n" +
                "  cx a,b;\n" +
                "}\n" +
                "qreg cin[1];\n" +
                "qreg a[4];\n" +
                "qreg b[4];\n" +
                "qreg cout[1];\n" +
                "creg ans[5];\n" +
                "// set input states\n" +
                "x a[0];\n" +
                "x b;\n" +
                "// add a to b, storing result in b\n" +
                "majority cin[0],b[0],a[0];\n" +
                "majority a[0],b[1],a[1];\n" +
                "majority a[1],b[2],a[2];\n" +
                "majority a[2],b[3],a[3];\n" +
                "cx a[3],cout[0];\n" +
                "unmaj a[2],b[3],a[3];\n" +
                "unmaj a[1],b[2],a[2];\n" +
                "unmaj a[0],b[1],a[1];\n" +
                "unmaj cin[0],b[0],a[0];\n" +
                "measure b[0] -> ans[0];\n" +
                "measure b[1] -> ans[1];\n" +
                "measure b[2] -> ans[2];\n" +
                "measure b[3] -> ans[3];\n" +
        "measure cout[0] -> ans[4];"

        let aId = QId("a")
        let bId = QId("b")
        let c = QId("c")
        var circuit = QuantumCircuit()
        circuit += Include("qelib1.inc")
        var gateDecl = GateDecl("majority", [], [aId, bId, c])
        gateDecl += QCX(c, bId)
        gateDecl += QCX(c, aId)
        gateDecl += Gate("ccx", [], [aId, bId, c])
        circuit += gateDecl
        gateDecl = GateDecl("unmaj", [], [aId, bId, c])
        gateDecl += Gate("ccx", [], [aId, bId, c])
        gateDecl += QCX(c, aId)
        gateDecl += QCX(aId, bId)
        circuit += gateDecl
        let cin = QuantumRegister("cin", 1)
        let a = QuantumRegister("a", 4)
        let b = QuantumRegister("b", 4)
        let cout = QuantumRegister("cout", 1)
        let ans = ClassicalRegister("ans", 5)
        circuit += cin
        circuit += a
        circuit += b
        circuit += cout
        circuit += ans
        circuit += Comment("set input states")
        circuit += Gate("x", [], [a[0]])
        circuit += Gate("x", [], [b])
        circuit += Comment("add a to b, storing result in b")
        circuit += Gate("majority", [], [cin[0], b[0], a[0]])
        circuit += Gate("majority", [], [a[0], b[1], a[1]])
        circuit += Gate("majority", [], [a[1], b[2], a[2]])
        circuit += Gate("majority", [], [a[2], b[3], a[3]])
        circuit += QCX(a[3], cout[0])
        circuit += Gate("unmaj", [], [a[2], b[3], a[3]])
        circuit += Gate("unmaj", [], [a[1], b[2], a[2]])
        circuit += Gate("unmaj", [], [a[0], b[1], a[1]])
        circuit += Gate("unmaj", [], [cin[0], b[0], a[0]])
        circuit += Measure(b[0], ans[0])
        circuit += Measure(b[1], ans[1])
        circuit += Measure(b[2], ans[2])
        circuit += Measure(b[3], ans[3])
        circuit += Measure(cout[0], ans[4])

        print(circuit.description)
        XCTAssertEqual(str, circuit.description)
        /*
         do {
            var compile = QuantumProgram.QASMCompile()
            compile.backend = "simulator"
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            self.runJob(QuantumProgram(config, compile, circuit))
         } catch let error {
            XCTFail("\(error)")
         }
         */
    }

    func testQFTAndMeasure2() {
        let str: String =
            "OPENQASM 2.0;\n" +
                "// QFT and measure, version 2\n" +
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
                "if(c0==1) u1(pi/2) q[1];\n" +
                "h q[1];\n" +
                "measure q[1] -> c1[0];\n" +
                "if(c0==1) u1(pi/4) q[2];\n" +
                "if(c1==1) u1(pi/2) q[2];\n" +
                "h q[2];\n" +
                "measure q[2] -> c2[0];\n" +
                "if(c0==1) u1(pi/8) q[3];\n" +
                "if(c1==1) u1(pi/4) q[3];\n" +
                "if(c2==1) u1(pi/2) q[3];\n" +
                "h q[3];\n" +
        "measure q[3] -> c3[0];"

        let q = QuantumRegister("q", 4)
        let c0 = ClassicalRegister("c0", 1)
        let c1 = ClassicalRegister("c1", 1)
        let c2 = ClassicalRegister("c2", 1)
        let c3 = ClassicalRegister("c3", 1)
        var circuit = QuantumCircuit()
        circuit += Comment("QFT and measure, version 2")
        circuit += Include("qelib1.inc")
        circuit += q
        circuit += c0
        circuit += c1
        circuit += c2
        circuit += c3
        circuit += Gate("h", [], [q])
        circuit += Barrier([q])
        circuit += Gate("h", [], [q[0]])
        circuit += Measure(q[0], c0[0])
        circuit += QIf(c0, 1, Gate("u1", ["pi/2"], [q[1]]))
        circuit += Gate("h", [], [q[1]])
        circuit += Measure(q[1], c1[0])
        circuit += QIf(c0, 1, Gate("u1", ["pi/4"], [q[2]]))
        circuit += QIf(c1, 1, Gate("u1", ["pi/2"], [q[2]]))
        circuit += Gate("h", [], [q[2]])
        circuit += Measure(q[2], c2[0])
        circuit += QIf(c0, 1, Gate("u1", ["pi/8"], [q[3]]))
        circuit += QIf(c1, 1, Gate("u1", ["pi/4"], [q[3]]))
        circuit += QIf(c2, 1, Gate("u1", ["pi/2"], [q[3]]))
        circuit += Gate("h", [], [q[3]])
        circuit += Measure(q[3], c3[0])

        print(circuit.description)
        XCTAssertEqual(str, circuit.description)
        /*
         do {
            var compile = QuantumProgram.QASMCompile()
            compile.backend = "simulator"
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            self.runJob(QuantumProgram(config, compile, circuit))
         } catch let error {
            XCTFail("\(error)")
         }
         */
    }

    private func runJob(_ program: QuantumProgram) {
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
