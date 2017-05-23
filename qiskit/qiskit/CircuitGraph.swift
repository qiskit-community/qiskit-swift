//
//  CircuitGraph.swift
//  qiskit
//
//  Created by Manoel Marques on 5/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa
import SwiftGraph


final class GraphNode: Equatable {
    public let name: HashableTuple<String,Int>
    public let type: String

    public init(_ name: HashableTuple<String,Int>, _ type: String) {
        self.name = name
        self.type = type
    }

    public static func ==(lhs: GraphNode, rhs: GraphNode) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}

public final class CicuitGraphEdgeData {
    public let name: HashableTuple<String,Int>

    public init(_ name: HashableTuple<String,Int>) {
        self.name = name
    }
}

public final class CircuitGraphEdge: UnweightedEdge {

    public var array: [CicuitGraphEdgeData] = []

    public init(u: Int, v: Int) {
        super.init(u: u, v: v, directed: true)
    }
}

class CircuitGraph<T: Equatable>: Graph<T> {

}
