//
//  GraphVertex.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class GraphVertex<VertexDataType: NSCopying> : Hashable, Equatable {

    public let key: Int
    public var data: VertexDataType? = nil
    var neighbors: Set<Int> = []

    public var hashValue : Int {
        get {
            return self.key.hashValue
        }
    }

    public init(_ key: Int) {
        self.key = key
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = GraphVertex<VertexDataType>(self.key)
        if self.data != nil {
            let d = self.data!.copy(with: zone) as! VertexDataType
            copy.data = d
        }
        copy.neighbors =  self.neighbors
        return copy
    }

    public static func ==<VertexDataType: NSCopying>(lhs: GraphVertex<VertexDataType>, rhs: GraphVertex<VertexDataType>) -> Bool {
        return lhs.key == rhs.key
    }
}

