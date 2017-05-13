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
            "IBMQASM 2.0;\n" +
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
        let q = Qqreg("q", 5)
        let c = Qcreg("c", 5)
        let qasm = QASM()
            .append(QComment("Simple 5 qubit test"))
            .append(QInclude("qelib1.inc"))
            .append(q)
            .append(c)
            .append(QGate("x", [], [q[0]]))
            .append(QGate("x", [], [q[1]]))
            .append(QGate("h", [], [q[2]]))
            .append(QMeasure(q[0], c[0]))
            .append(QMeasure(q[1], c[1]))
            .append(QMeasure(q[2], c[2]))
            .append(QMeasure(q[3], c[3]))
            .append(QMeasure(q[4], c[4]))
        print(qasm)
        XCTAssertEqual(str, qasm.description)
        //self.runJobToCompletion(qasm.description, IBMQuantumExperience.Device.real)
    }
    
    func testMakeBell1() {
        let makeBell: String =
            "IBMQASM 2.0;\n" +
                "// Make Bell\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
        "measure q[2] -> c[1];"
        
        let q = Qqreg("q", 3)
        let c = Qcreg("c", 2)
        let qasm = QASM().append(contentsOf:
            [QComment("Make Bell"),
             QInclude("qelib1.inc"),
             q,
             c,
             QGate("h", [], [q[0]]),
             QCX(q[0], q[2]),
             QMeasure(q[0], c[0]),
             QMeasure(q[2], c[1])])
        print(qasm)
        XCTAssertEqual(makeBell, qasm.description)
        //self.runExperiment(qasm.description, IBMQuantumExperience.Device.simulator)
    }
    
    func testMakeBell2() {
        let makeBell: String =
            "IBMQASM 2.0;\n" +
                "// Make Bell\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
        "measure q[2] -> c[1];"
        
        let q = Qqreg("q", 3)
        let c = Qcreg("c", 2)
        let qasm = QASM()
            + QComment("Make Bell")
            + QInclude("qelib1.inc")
            + q
            + c
            + QGate("h", [], [q[0]])
            + QCX(q[0], q[2])
            + QMeasure(q[0], c[0])
            + QMeasure(q[2], c[1])
        print(qasm)
        XCTAssertEqual(makeBell, qasm.description)
        //self.runJobToCompletion(qasm.description, IBMQuantumExperience.Device.simulator)
    }
    
    func testMakeBell3() {
        let makeBell: String =
            "IBMQASM 2.0;\n" +
                "// Make Bell\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
        "measure q[2] -> c[1];"
        
        let q = Qqreg("q", 3)
        let c = Qcreg("c", 2)
        var qasm = QASM()
        qasm += QComment("Make Bell")
        qasm += QInclude("qelib1.inc")
        qasm += q
        qasm += c
        qasm += QGate("h", [], [q[0]])
        qasm += QCX(q[0], q[2])
        qasm += QMeasure(q[0], c[0])
        qasm += QMeasure(q[2], c[1])
        print(qasm)
        XCTAssertEqual(makeBell, qasm.description)
    }
    
    func testRippleCarryAdder() {
        let rca: String =
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
        var qasm = QASM(QASM.QASMFormat.qasmOpen)
        qasm += QInclude("qelib1.inc")
        var gateDecl = QGateDecl("majority", [], [aId, bId, c])
        gateDecl += QCX(c, bId)
        gateDecl += QCX(c, aId)
        gateDecl += QGate("ccx", [], [aId, bId, c])
        qasm += gateDecl
        gateDecl = QGateDecl("unmaj", [], [aId, bId, c])
        gateDecl += QGate("ccx", [], [aId, bId, c])
        gateDecl += QCX(c, aId)
        gateDecl += QCX(aId, bId)
        qasm += gateDecl
        let cin = Qqreg("cin", 1)
        let a = Qqreg("a", 4)
        let b = Qqreg("b", 4)
        let cout = Qqreg("cout", 1)
        let ans = Qcreg("ans", 5)
        qasm += cin
        qasm += a
        qasm += b
        qasm += cout
        qasm += ans
        qasm += QComment("set input states")
        qasm += QGate("x", [], [a[0]])
        qasm += QGate("x", [], [b])
        qasm += QComment("add a to b, storing result in b")
        qasm += QGate("majority", [], [cin[0], b[0], a[0]])
        qasm += QGate("majority", [], [a[0], b[1], a[1]])
        qasm += QGate("majority", [], [a[1], b[2], a[2]])
        qasm += QGate("majority", [], [a[2], b[3], a[3]])
        qasm += QCX(a[3], cout[0])
        qasm += QGate("unmaj", [], [a[2], b[3], a[3]])
        qasm += QGate("unmaj", [], [a[1], b[2], a[2]])
        qasm += QGate("unmaj", [], [a[0], b[1], a[1]])
        qasm += QGate("unmaj", [], [cin[0], b[0], a[0]])
        qasm += QMeasure(b[0], ans[0])
        qasm += QMeasure(b[1], ans[1])
        qasm += QMeasure(b[2], ans[2])
        qasm += QMeasure(b[3], ans[3])
        qasm += QMeasure(cout[0], ans[4])
        
        print(qasm)
        XCTAssertEqual(rca, qasm.description)
        //self.runExperiment(qasm.description, IBMQuantumExperience.Device.simulator)
    }
    
    func testQFTAndMeasure2() {
        let qasmString: String =
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
        
        let q = Qqreg("q", 4)
        let c0 = Qcreg("c0", 1)
        let c1 = Qcreg("c1", 1)
        let c2 = Qcreg("c2", 1)
        let c3 = Qcreg("c3", 1)
        var qasm = QASM(QASM.QASMFormat.qasmOpen)
        qasm += QComment("QFT and measure, version 2")
        qasm += QInclude("qelib1.inc")
        qasm += q
        qasm += c0
        qasm += c1
        qasm += c2
        qasm += c3
        qasm += QGate("h", [], [q])
        qasm += QBarrier([q])
        qasm += QGate("h", [], [q[0]])
        qasm += QMeasure(q[0], c0[0])
        qasm += QIf(c0, 1, QGate("u1", ["pi/2"], [q[1]]))
        qasm += QGate("h", [], [q[1]])
        qasm += QMeasure(q[1], c1[0])
        qasm += QIf(c0, 1, QGate("u1", ["pi/4"], [q[2]]))
        qasm += QIf(c1, 1, QGate("u1", ["pi/2"], [q[2]]))
        qasm += QGate("h", [], [q[2]])
        qasm += QMeasure(q[2], c2[0])
        qasm += QIf(c0, 1, QGate("u1", ["pi/8"], [q[3]]))
        qasm += QIf(c1, 1, QGate("u1", ["pi/4"], [q[3]]))
        qasm += QIf(c2, 1, QGate("u1", ["pi/2"], [q[3]]))
        qasm += QGate("h", [], [q[3]])
        qasm += QMeasure(q[3], c3[0])
        
        print(qasm)
        XCTAssertEqual(qasmString, qasm.description)
        //self.runExperiment(qasm.description, IBMQuantumExperience.Device.simulator)
    }
    
    private func runJobToCompletion(_ qasm: String, _ device: IBMQuantumExperience.Device) {
        let asyncExpectation = self.expectation(description: "testJobFunction")
        
        do {
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            let api = IBMQuantumExperience(config: config)
            api.runJobToCompletion(qasms: [qasm], device: device,
                                   shots: 1024, maxCredits: 3) { (result, error) in
                                    if error != nil {
                                        XCTFail("Failure in runJobToCompletion: \(error!)")
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
                                    api.getExecution(idExecution) { (execution, error) in
                                        if error != nil {
                                            XCTFail("Failure in runJobToCompletion: \(error!)")
                                            asyncExpectation.fulfill()
                                            return
                                        }
                                        print("Execution: \(execution!)")
                                        api.getResultFromExecution(idExecution) { (result, error) in
                                            defer {
                                                asyncExpectation.fulfill()
                                            }
                                            if error != nil {
                                                XCTFail("Failure in runJobToCompletion: \(error!)")
                                                return
                                            }
                                            print("Result: \(result!)")
                                        }
                                    }
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in runJobToCompletion")
            })
        } catch let error {
            XCTFail("Failure in runJobToCompletion: \(error)")
        }
    }
    
    private func runExperiment(_ qasm: String, _ device: IBMQuantumExperience.Device) {
        let asyncExpectation = self.expectation(description: "runExperimentFunction")
        
        do {
            let config = try Qconfig(apiToken: QiskitTests.APItoken, url: QiskitTests.TESTURL)
            let api = IBMQuantumExperience(config: config)
            api.runExperiment(qasm: qasm, device: device,
                              shots: 1024, timeOut: 60) { (result, error) in
                                if error != nil {
                                    XCTFail("Failure in runExperiment: \(error!)")
                                    asyncExpectation.fulfill()
                                    return
                                }
                                print("Result: \(result!)")
                                api.getImageCode((result?.codeId)!) { (out, error) in
                                    defer {
                                        asyncExpectation.fulfill()
                                    }
                                    if error != nil {
                                        XCTFail("Failure in runExperiment: \(error!)")
                                        return
                                    }
                                    print("Result: \(out!)")
                                }
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in runExperiment")
            })
        } catch let error {
            XCTFail("Failure in runExperiment: \(error)")
        }
    }
    
    /*
     func testPerformanceExample() {
     // This is an example of a performance test case.
     self.measure {
     // Put the code you want to measure the time of here.
     }
     }
     */
}
