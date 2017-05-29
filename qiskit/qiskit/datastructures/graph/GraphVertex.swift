//
//  GraphVertex.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class GraphVertex<VertexDataType: NSCopying,EdgeDataType: NSCopying> {

    public let key: Int
    public var data: VertexDataType? = nil
    var neighbors: [GraphEdge<EdgeDataType,VertexDataType>] = []

    public init(_ key: Int) {
        self.key = key
    }
    public func edge(_ neighborKey: Int) -> GraphEdge<EdgeDataType,VertexDataType>? {
        for edge in self.neighbors {
            if edge.neighbor.key == neighborKey {
                return edge
            }
        }
        return nil
    }

}

