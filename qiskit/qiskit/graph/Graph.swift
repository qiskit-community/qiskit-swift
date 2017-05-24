//
//  Graph.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public class Graph<VertexDataType,EdgeDataType> {

    private var vertexMap: [Int:GraphVertex<VertexDataType,EdgeDataType>] = [:]
    public let isDirected: Bool
    public private (set) var edges: [GraphEdge<EdgeDataType,VertexDataType>] = []

    public var vertexList: [GraphVertex<VertexDataType,EdgeDataType>] {
        return Array(self.vertexMap.values)
    }

    public init(_ isDirected: Bool) {
        self.isDirected = isDirected
    }

    public func vertex(_ key: Int) -> GraphVertex<VertexDataType,EdgeDataType>? {
        return self.vertexMap[key]
    }

    public func edge(_ sourceIndex: Int, _ neighborIndex: Int) -> GraphEdge<EdgeDataType,VertexDataType>? {
        guard let source = self.vertexMap[sourceIndex] else {
            return nil
        }
        return source.neighborsMap[neighborIndex]
    }

    public func add_edge(_ sourceIndex: Int, _ neighborIndex: Int, _ weight: Int = 0) {
        if self.vertexMap[sourceIndex] == nil {
            self.vertexMap[sourceIndex] = GraphVertex(sourceIndex)
        }
        guard let source = self.vertexMap[sourceIndex] else {
            return
        }
        if self.vertexMap[neighborIndex] == nil {
            self.vertexMap[neighborIndex] = GraphVertex(neighborIndex)
        }
        guard let neighbor = self.vertexMap[neighborIndex] else {
            return
        }
        var edge = GraphEdge(source,neighbor,weight)
        source.neighborsMap[edge.neighbor.key] = edge
        self.edges.append(edge)
        if !self.isDirected {
            edge = GraphEdge(neighbor,source,weight)
            neighbor.neighborsMap[edge.neighbor.key] = edge
            self.edges.append(edge)
        }
    }
}
