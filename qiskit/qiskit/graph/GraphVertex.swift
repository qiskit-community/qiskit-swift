//
//  GraphVertex.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class GraphVertex<VertexDataType,EdgeDataType> {

    public let key: Int
    public var data: VertexDataType? = nil
    var neighborsMap: [Int:GraphEdge<EdgeDataType,VertexDataType>] = [:]

    public init(_ key: Int) {
        self.key = key
    }
}

