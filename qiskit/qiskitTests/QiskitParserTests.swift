//
//  QiskitParserTests.swift
//  qiskit
//
//  Created by Joe Ligman on 5/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest

class QiskitParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParserREAL() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("5.0")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(5.0, value)
            asyncExpectation.fulfill()
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

    func testParserNNINTEGER() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("5")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(5, value)
            asyncExpectation.fulfill()
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

    func testParserADD() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("5 + 4.0")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(9.0, value)
            asyncExpectation.fulfill()
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

    func testParserSUBTRACT() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("5 - 4.0")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(1.0, value)
            asyncExpectation.fulfill()
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
    
    func testParserMULTIPLY() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("5 * 4.0")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(20.0, value)
            asyncExpectation.fulfill()
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

    func testParserDIVIDE() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("25 / 5")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(5, value)
            asyncExpectation.fulfill()
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

    func testParserADDDIVIDE() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("(20 + 5) / 5")
        
        ParseSuccessBlock = { (value: Float) -> Void in
            XCTAssertEqual(5, value)
            asyncExpectation.fulfill()
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
