//
//  QIskitParserTerminalTests.swift
//  qiskit
//
//  Created by Joe Ligman on 5/26/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
@testable import qiskit

class QIskitParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParser() {
        do {
            let qasmProgram: String =
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

            let parser = Qasm(data: qasmProgram)
            let root = try parser.parse()
            let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
            let emittedQasm = root.qasm().components(separatedBy: whitespaceCharacterSet).joined()
            let targetQasm = qasmProgram.components(separatedBy: whitespaceCharacterSet).joined()
            XCTAssertEqual(emittedQasm, targetQasm)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    func testErrorCorrection() {
        do {
            let qasmProgram: String =
                "OPENQASM 2.0;\n" +
                    "include \"qelib1.inc\";\n" +
                    "qreg q[3];\n" +
                    "qreg a[2];\n" +
                    "creg c[3];\n" +
                    "creg syn[2];\n" +
                    "gate syndrome d1, d2, d3, a1, a2\n" +
                    "{\n" +
                    "    cx d1, a1; cx d2, a1;\n" +
                    "    cx d2, a2; cx d3, a2;\n" +
                    "}\n" +
                    "x q[0];\n" +
                    "barrier q;\n" +
                    "syndrome q[0],q[1],q[2],a[0],a[1];\n" +
                    "measure a -> syn;\n" +
                    "if(syn==1) x q[0];\n" +
                    "if(syn==2) x q[2];\n" +
                    "if(syn==3) x q[1];\n" +
                    "measure q -> c;\n"

            let parser = Qasm(data: qasmProgram)
            let root = try parser.parse()
            let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
            let emittedQasm = root.qasm().components(separatedBy: whitespaceCharacterSet).joined()
            let targetQasm = qasmProgram.components(separatedBy: whitespaceCharacterSet).joined()
            XCTAssertEqual(emittedQasm, targetQasm)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    

    func testParserBell () {
        
        do {
            let qasmProgram: String =
                "OPENQASM 2.0;\n" +
                    "include \"qelib1.inc\";\n" +
                    "qreg q[3];\n" +
                    "creg c[2];\n" +
                    "h q[0];\n" +
                    "cx q[0],q[2];\n" +
                    "measure q[0] -> c[0];\n" +
                    "measure q[2] -> c[1];"
            
            let parser = Qasm(data: qasmProgram)
            let root = try parser.parse()
            let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
            let emittedQasm = root.qasm().components(separatedBy: whitespaceCharacterSet).joined()
            let targetQasm = qasmProgram.components(separatedBy: whitespaceCharacterSet).joined()
            XCTAssertEqual(emittedQasm, targetQasm)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    func testParserRipple () {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let qasmProgram: String =
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
        
        let buf: YY_BUFFER_STATE = yy_scan_string(qasmProgram)
        
        ParseSuccessBlock = { (n: NSObject?) -> Void in
            XCTAssertNotNil(n)
            if let node = n as? NodeMainProgram {
                let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
                let emittedQasm = node.qasm().components(separatedBy: whitespaceCharacterSet).joined()
                let targetQasm = qasmProgram.components(separatedBy: whitespaceCharacterSet).joined()
                XCTAssertEqual(emittedQasm, targetQasm)
                asyncExpectation.fulfill()
            } else {
                XCTFail("Main Program Node Type Expected!")
                asyncExpectation.fulfill()
                return
            }
            
        }
        
        ParseFailBlock = { (message: String?) -> Void in
            if let msg = message {
                XCTFail(msg)
            } else {
                XCTFail("Unknown Error")
            }
            asyncExpectation.fulfill()
        }
        
        yyparse()
        yy_delete_buffer(buf)
        
        self.waitForExpectations(timeout: 180, handler: { (error) in
            XCTAssertNil(error, "Failure in parser")
        })
        
    }
    
    func testParserExpressionList () {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        do {
            let qasmProgram: String =
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
                    "u1(0.3) qr[0];\n" +
                    "u2(0.3,0.2) qr[1];\n" +
                    "u3(0.3,0.2,0.1) qr[2];\n" +
                    "s qr[0];\n" +
                    "t qr[1];\n" +
                    "id qr[1];\n" +
                    "measure qr[0] -> cr[0];"
            
            let buf: YY_BUFFER_STATE = yy_scan_string(qasmProgram)
            
            ParseSuccessBlock = { (n: NSObject?) -> Void in
                XCTAssertNotNil(n)
                if let node = n as? NodeMainProgram {
                    let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
                    let emittedQasm = node.qasm().components(separatedBy: whitespaceCharacterSet).joined()
                    let targetQasm = qasmProgram.components(separatedBy: whitespaceCharacterSet).joined()
                    XCTAssertEqual(emittedQasm, targetQasm)
                    asyncExpectation.fulfill()
                } else {
                    XCTFail("Main Program Node Type Expected!")
                    asyncExpectation.fulfill()
                    return
                }
                
            }
            
            ParseFailBlock = { (message: String?) -> Void in
                if let msg = message {
                    XCTFail(msg)
                } else {
                    XCTFail("Unknown Error")
                }
                asyncExpectation.fulfill()
            }
            
            yyparse()
            yy_delete_buffer(buf)
            
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in parser")
            })
            
        }
    }
    
}
