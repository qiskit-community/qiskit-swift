//
//  DataStructureTests.swift
//  qiskit
//
//  Created by Manoel Marques on 5/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import XCTest
@testable import qiskit

class DataStructureTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOrderedDictionary() {
        var dict: OrderedDictionary<Int,String> = OrderedDictionary<Int,String>()
        dict[4] = "Four"
        dict[8] = "Eight"
        dict[15] = "Fifteen"
        XCTAssertEqual(dict.description, "[\"4\": \"Four\",\"8\": \"Eight\",\"15\": \"Fifteen\"]")
        dict[1] = nil
        dict[4] = nil
        XCTAssertEqual(dict.description, "[\"8\": \"Eight\",\"15\": \"Fifteen\"]")
    }

    func testTopologicalSort() {
        do {
            let g = Graph<NSString,NSString>(directed: true)
            g.add_edge(5, 2)
            g.add_edge(5, 0)
            g.add_edge(4, 0)
            g.add_edge(4, 1)
            g.add_edge(2, 3)
            g.add_edge(3, 1)

            var str = try DataStructureTests.formatList(g.topological_sort())
            XCTAssertEqual(str, "4 5 0 2 3 1")
            str = try DataStructureTests.formatList(g.topological_sort(reverse: true))
            XCTAssertEqual(str, "1 3 2 0 5 4")
        } catch let error {
            XCTFail("\(error)")
        }
    }

    func testPredecessors() {
        let g = Graph<NSString,NSString>(directed: true)
        g.add_edge(5, 2)
        g.add_edge(5, 0)
        g.add_edge(4, 0)
        g.add_edge(4, 1)
        g.add_edge(2, 3)
        g.add_edge(3, 1)

        var str = DataStructureTests.formatList(g.predecessors(0))
        XCTAssertEqual(str, "5 4")
        str = DataStructureTests.formatList(g.predecessors(1))
        XCTAssertEqual(str, "4 3")
        str = DataStructureTests.formatList(g.predecessors(2))
        XCTAssertEqual(str, "5")
        str = DataStructureTests.formatList(g.predecessors(3))
        XCTAssertEqual(str, "2")
        str = DataStructureTests.formatList(g.predecessors(4))
        XCTAssertEqual(str, "")
        str = DataStructureTests.formatList(g.predecessors(5))
        XCTAssertEqual(str, "")
    }

    func testAncestors() {
        let g = Graph<NSString,NSString>(directed: true)
        g.add_edge(5, 2)
        g.add_edge(5, 0)
        g.add_edge(4, 0)
        g.add_edge(4, 1)
        g.add_edge(2, 3)
        g.add_edge(3, 1)

        var str = DataStructureTests.formatList(g.ancestors(0))
        XCTAssertEqual(str, "5 4")
        str = DataStructureTests.formatList(g.ancestors(1))
        XCTAssertEqual(str, "3 2 5 4")
        str = DataStructureTests.formatList(g.ancestors(2))
        XCTAssertEqual(str, "5")
        str = DataStructureTests.formatList(g.ancestors(3))
        XCTAssertEqual(str, "2 5")
        str = DataStructureTests.formatList(g.ancestors(4))
        XCTAssertEqual(str, "")
        str = DataStructureTests.formatList(g.ancestors(5))
        XCTAssertEqual(str, "")
    }

    func testSuccessors() {
        let g = Graph<NSString,NSString>(directed: true)
        g.add_edge(5, 2)
        g.add_edge(5, 0)
        g.add_edge(4, 0)
        g.add_edge(4, 1)
        g.add_edge(2, 3)
        g.add_edge(3, 1)

        var str = DataStructureTests.formatList(g.successors(0))
        XCTAssertEqual(str, "")
        str = DataStructureTests.formatList(g.successors(1))
        XCTAssertEqual(str, "")
        str = DataStructureTests.formatList(g.successors(2))
        XCTAssertEqual(str, "3")
        str = DataStructureTests.formatList(g.successors(3))
        XCTAssertEqual(str, "1")
        str = DataStructureTests.formatList(g.successors(4))
        XCTAssertEqual(str, "0 1")
        str = DataStructureTests.formatList(g.successors(5))
        XCTAssertEqual(str, "2 0")
    }

    func testDescendants() {
        let g = Graph<NSString,NSString>(directed: true)
        g.add_edge(5, 2)
        g.add_edge(5, 0)
        g.add_edge(4, 0)
        g.add_edge(4, 1)
        g.add_edge(2, 3)
        g.add_edge(3, 1)

        var str = DataStructureTests.formatList(g.descendants(0))
        XCTAssertEqual(str, "")
        str = DataStructureTests.formatList(g.descendants(1))
        XCTAssertEqual(str, "")
        str = DataStructureTests.formatList(g.descendants(2))
        XCTAssertEqual(str, "3 1")
        str = DataStructureTests.formatList(g.descendants(3))
        XCTAssertEqual(str, "1")
        str = DataStructureTests.formatList(g.descendants(4))
        XCTAssertEqual(str, "0 1")
        str = DataStructureTests.formatList(g.descendants(5))
        XCTAssertEqual(str, "2 3 1 0")
    }

    func testWeaklyConnetectedComponents() {
        do {
            let g = Graph<NSString,NSString>(directed: true)
            g.add_edge(1, 0)
            g.add_edge(2, 3)
            g.add_edge(3, 4)

            let count = try g.number_weakly_connected_components()
            XCTAssertEqual(count, 2)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    func testLongestPath() {
        do {
            var g = Graph<NSString,NSString>(directed: true)
            g.add_edge(0, 1)
            g.add_edge(0, 2)
            g.add_edge(1, 3)
            g.add_edge(1, 2)
            g.add_edge(2, 4)
            g.add_edge(2, 5)
            g.add_edge(2, 3)
            g.add_edge(3, 5)
            g.add_edge(3, 4)
            g.add_edge(4, 5)

            var str = DataStructureTests.formatList(try g.dag_longest_path())
            XCTAssertEqual(str, "0 1 2 3 4 5")
            var count = try g.dag_longest_path_length()
            XCTAssertEqual(count, 5)

            g = Graph<NSString,NSString>(directed: true)
            g.add_edge(5, 2)
            g.add_edge(5, 0)
            g.add_edge(4, 0)
            g.add_edge(4, 1)
            g.add_edge(2, 3)
            g.add_edge(3, 1)

            str = DataStructureTests.formatList(try g.dag_longest_path())
            XCTAssertEqual(str, "5 2 3 1")
            count = try g.dag_longest_path_length()
            XCTAssertEqual(count, 3)
        } catch let error {
            XCTFail("\(error)")
        }
    }

    private class func formatList(_ list: [GraphVertex<NSString>]) -> String {
        var str = ""
        for vertex in list {
            if !str.isEmpty {
                str += " "
            }
            str += "\(vertex.key)"
        }
        return str
    }
}
