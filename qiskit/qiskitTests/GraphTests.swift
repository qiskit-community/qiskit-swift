//
//  GraphTests.swift
//  qiskit
//
//  Created by Manoel Marques on 5/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
@testable import qiskit

class GraphTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTopologicalSort() {
        let g = Graph<NSString,NSString>(true)
        g.add_edge(5, 2)
        g.add_edge(5, 0)
        g.add_edge(4, 0)
        g.add_edge(4, 1)
        g.add_edge(2, 3)
        g.add_edge(3, 1)

        var str = ""
        let list = g.topological_sort()
        for index in list {
            if !str.isEmpty {
                str += " "
            }
            str += "\(index)"
        }
        XCTAssertEqual(str, "4 5 0 2 3 1")
    }
}
