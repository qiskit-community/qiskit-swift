//
//  GraphEdge.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class GraphEdge<EdgeDataType: NSCopying,VertexDataType: NSCopying> {

    public var data: EdgeDataType? = nil
    public let source: GraphVertex<VertexDataType,EdgeDataType>
    public let neighbor: GraphVertex<VertexDataType,EdgeDataType>

    init(_ source: GraphVertex<VertexDataType,EdgeDataType>, _ neighbor: GraphVertex<VertexDataType,EdgeDataType>) {
        self.source = source
        self.neighbor = neighbor
    }
}
