//
//  QiskitParserExpTests.swift
//  qiskit
//
//  Created by Joe Ligman on 5/22/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest

class QiskitParserExpTests: XCTestCase {

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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            guard let nr = node as? NodeReal else {
                XCTFail("Real Node Type Expected!")
                asyncExpectation.fulfill()
                return
            }
            XCTAssertEqual(5.0, nr.real)
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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            guard let nni = node as? NodeNNInteger else {
                XCTFail("Real Node Type Expected!")
                asyncExpectation.fulfill()
                return
            }
            XCTAssertEqual(5, nni.nnInteger)
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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            XCTAssertEqual(Character("+"), Character(UnicodeScalar(Int(node!.nodeType))!))
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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            XCTAssertEqual(Character("-"), Character(UnicodeScalar(Int(node!.nodeType))!))
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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            XCTAssertEqual(Character("*"), Character(UnicodeScalar(Int(node!.nodeType))!))
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
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            XCTAssertEqual(Character("/"), Character(UnicodeScalar(Int(node!.nodeType))!))
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

    func testParserSIN() {
        
        let asyncExpectation = self.expectation(description: "parser")
        
        let buf: YY_BUFFER_STATE = yy_scan_string("sin(90)")
        
        ParseSuccessBlock = { (node: Node?) -> Void in
            XCTAssertNotNil(node)
            XCTAssertEqual(Character("U"), Character(UnicodeScalar(Int(node!.nodeType))!))
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
