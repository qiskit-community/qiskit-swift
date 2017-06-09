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
