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
    public var neighbors: [Int] {
        get {
            return self._neighbors.sorted()
        }
    }
    public var hashValue : Int {
        get {
            return self.key.hashValue
        }
    }
    private var _neighbors: Set<Int> = []

    public init(_ key: Int) {
        self.key = key
    }

    func addNeighbor(_ key: Int) {
        self._neighbors.update(with: key)
    }

    func removeNeighbor(_ key: Int) {
        self._neighbors.remove(key)
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = GraphVertex<VertexDataType>(self.key)
        if self.data != nil {
            let d = self.data!.copy(with: zone) as! VertexDataType
            copy.data = d
        }
        copy._neighbors =  self._neighbors
        return copy
    }

    public static func ==<VertexDataType: NSCopying>(lhs: GraphVertex<VertexDataType>, rhs: GraphVertex<VertexDataType>) -> Bool {
        return lhs.key == rhs.key
    }
}

