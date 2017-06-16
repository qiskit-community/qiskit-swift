//
//  QIskitParserTerminalTests.swift
//  qiskit
//
//  Created by Joe Ligman on 5/26/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
import qiskit

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
        
        let asyncExpectation = self.expectation(description: "parser")
        
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
        
        let buf: YY_BUFFER_STATE = yy_scan_string(qasmProgram)
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            if node is NodeMainProgram {
                let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
                let emittedQasm = node!.qasm().components(separatedBy: whitespaceCharacterSet).joined()
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
    
    func testParserBell () {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let qasmProgram: String =
            "OPENQASM 2.0;\n" +
                "include \"qelib1.inc\";\n" +
                "qreg q[3];\n" +
                "creg c[2];\n" +
                "h q[0];\n" +
                "cx q[0],q[2];\n" +
                "measure q[0] -> c[0];\n" +
                "measure q[2] -> c[1];"
        
        let buf: YY_BUFFER_STATE = yy_scan_string(qasmProgram)
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            if node is NodeMainProgram {
                let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
                let emittedQasm = node!.qasm().components(separatedBy: whitespaceCharacterSet).joined()
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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            if node is NodeMainProgram {
                let whitespaceCharacterSet = CharacterSet.whitespacesAndNewlines
                let emittedQasm = node!.qasm().components(separatedBy: whitespaceCharacterSet).joined()
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
