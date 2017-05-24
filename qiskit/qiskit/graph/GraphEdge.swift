//
//  GraphEdge.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class GraphEdge<EdgeDataType,VertexDataType> {

    public var data: EdgeDataType? = nil
    public let neighbor: GraphVertex<VertexDataType,EdgeDataType>
    public let weight: Int

    init(_ neighbor: GraphVertex<VertexDataType,EdgeDataType>, _ weight: Int) {
        self.neighbor = neighbor
        self.weight = weight
    }
}
