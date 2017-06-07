//
//  QiskitParserArgTests.swift
//  qiskit
//
//  Created by Joe Ligman on 5/26/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
import qiskit

class QiskitParserArgTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParserArgument() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("q[5]")
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            if node is NodeArgument {
                asyncExpectation.fulfill()
            } else {
                XCTFail("NodeArgument Type Expected!")
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

    func testParserUop() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("U (5.0 + 40) joe;")
      
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            if node is NodeUniversalUnitary {
                asyncExpectation.fulfill()
            } else {
                XCTFail("NodeUniversalUnitary Type Expected!")
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
