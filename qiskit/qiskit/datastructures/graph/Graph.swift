//
//  Graph.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class Graph<VertexDataType: NSCopying,EdgeDataType: NSCopying>: NSCopying {

    public private(set) var vertexList: [GraphVertex<VertexDataType,EdgeDataType>] = []
    public let isDirected: Bool

    public var edges: [GraphEdge<EdgeDataType,VertexDataType>] {
        var edges: [GraphEdge<EdgeDataType,VertexDataType>] = []
        for vertex in self.vertexList {
            for edge in vertex.neighbors {
                edges.append(edge)
            }
        }
        return edges
    }
   
    public init(_ isDirected: Bool) {
        self.isDirected = isDirected
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Graph(self.isDirected)
        for edge in self.edges {
            copy.add_edge(edge.source.key, edge.neighbor.key, edge.weight)
            if let e = self.edge(edge.source.key, edge.neighbor.key) {
                if let data = edge.data {
                    e.data = data.copy(with: zone) as? EdgeDataType
                }
                if let data = edge.source.data {
                    e.source.data = data.copy(with: zone) as? VertexDataType
                }
                if let data = edge.neighbor.data {
                    e.neighbor.data = data.copy(with: zone) as? VertexDataType
                }
            }
        }
        return copy
    }

    public func vertex(_ key: Int) -> GraphVertex<VertexDataType,EdgeDataType>? {
        for vertex in self.vertexList {
            if vertex.key == key {
                return vertex
            }
        }
        return nil
    }

    public func edge(_ sourceIndex: Int, _ neighborIndex: Int) -> GraphEdge<EdgeDataType,VertexDataType>? {
        guard let source = self.vertex(sourceIndex) else {
            return nil
        }
        return source.edge(neighborIndex)
    }

    public func add_edge(_ sourceIndex: Int, _ neighborIndex: Int, _ weight: Int = 0) {
        var source = self.vertex(sourceIndex)
        if source == nil {
            source = GraphVertex(sourceIndex)
            self.vertexList.append(source!)
        }
        var neighbor = self.vertex(neighborIndex)
        if neighbor == nil {
            neighbor = GraphVertex(neighborIndex)
            self.vertexList.append(neighbor!)
        }
        var edge = self.edge(sourceIndex,neighborIndex)
        if edge == nil {
            edge = GraphEdge(source!,neighbor!,weight)
            edge!.source.neighbors.append(edge!)
        }
        else {
            edge!.data = nil
            edge!.weight = weight
        }
        if !self.isDirected {
            edge = self.edge(neighborIndex,sourceIndex)
            if edge == nil {
                edge = GraphEdge(neighbor!,source!,weight)
                edge!.source.neighbors.append(edge!)
            }
            else {
                edge!.data = nil
                edge!.weight = weight
            }
        }
    }

    public func remove_vertex(_ index: Int) {
        if self.vertex(index) == nil {
            return
        }
        var newVertexList: [GraphVertex<VertexDataType,EdgeDataType>] = []
        for vertex in self.vertexList {
            if vertex.key != index {
                newVertexList.append(vertex)
                var newNeighborList: [GraphEdge<EdgeDataType,VertexDataType>] = []
                for edge in vertex.neighbors {
                    if edge.neighbor.key != index {
                        newNeighborList.append(edge)
                    }
                }
                vertex.neighbors = newNeighborList
            }
        }
        self.vertexList = newVertexList
    }

    public func in_edges_iter(_ index: Int) -> [GraphEdge<EdgeDataType,VertexDataType>] {
        if self.vertex(index) == nil {
            return []
        }
        var inEdges: [GraphEdge<EdgeDataType,VertexDataType>] = []
        for edge in self.edges {
            if edge.neighbor.key == index {
                inEdges.append(edge)
            }
        }
        return inEdges
    }

    public func out_edges_iter(_ index: Int) -> [GraphEdge<EdgeDataType,VertexDataType>] {
        guard let vertex = self.vertex(index) else {
            return []
        }
        return vertex.neighbors
    }

    public func topological_sort() -> [Int] {
        var stack = Stack<Int>()
        var visited = Set<Int>()

        for vertex in self.vertexList {
            if !visited.contains(vertex.key) {
                self.topologicalSortUtil(vertex, &visited, &stack)
            }
        }
        var vertexList: [Int] = []
        while !stack.isEmpty {
            vertexList.append(stack.pop())
        }
        return vertexList
    }

    private func topologicalSortUtil(_ vertex: GraphVertex<VertexDataType,EdgeDataType>, _ visited: inout Set<Int>, _ stack: inout Stack<Int>) {
        visited.update(with: vertex.key)
        for edge in vertex.neighbors {
            if !visited.contains(edge.neighbor.key) {
                self.topologicalSortUtil(edge.neighbor, &visited, &stack)
            }
        }
        stack.push(vertex.key)
    }
}
