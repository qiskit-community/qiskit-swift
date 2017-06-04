//
//  GraphVertex.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class GraphVertex<VertexDataType: NSCopying> {

    public let key: Int
    public var data: VertexDataType? = nil
    var neighbors: OrderedDictionary<Int,GraphVertex<VertexDataType>> = OrderedDictionary<Int,GraphVertex<VertexDataType>>()

    public init(_ key: Int) {
        self.key = key
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = GraphVertex<VertexDataType>(self.key)
        if self.data != nil {
            let d = self.data!.copy(with: zone) as! VertexDataType
            copy.data = d
        }
        for i in 0..<self.neighbors.count {
            let neighbor = self.neighbors.value(i).copy(with: zone) as! GraphVertex<VertexDataType>
            copy.neighbors[neighbor.key] = neighbor
        }
        return copy
    }
}

