//
//  GraphEdge.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

final class GraphEdge<EdgeDataType: NSCopying,VertexDataType: NSCopying> {

    public var data: EdgeDataType? = nil
    public let source: GraphVertex<VertexDataType,EdgeDataType>
    public let neighbor: GraphVertex<VertexDataType,EdgeDataType>
    public let weight: Int

    init(_ source: GraphVertex<VertexDataType,EdgeDataType>, _ neighbor: GraphVertex<VertexDataType,EdgeDataType>, _ weight: Int) {
        self.source = source
        self.neighbor = neighbor
        self.weight = weight
    }
}
