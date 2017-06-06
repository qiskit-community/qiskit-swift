//
//  QiskitParserExpListTests.swift
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
import qiskit

class QiskitParserExpListTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParserExpressionList() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("20 + 5, 20 - 5")
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            if node is NodeExpressionList {
                asyncExpectation.fulfill()
            } else {
                XCTFail("NodeExpressionList Type Expected!")
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
