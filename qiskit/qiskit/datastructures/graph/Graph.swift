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
        for vertex in self.vertexList {
            let v = copy.add_vertex(vertex.key)
            if let data = vertex.data {
                v.data = data.copy(with: zone) as? VertexDataType
            }
        }
        for edge in self.edges {
            var d:EdgeDataType? = nil
            if let data = edge.data {
                d = data.copy(with: zone) as? EdgeDataType
            }
            copy.add_edge(edge.source.key, edge.neighbor.key, d, edge.weight)
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

    public func add_vertex(_ key: Int) -> GraphVertex<VertexDataType,EdgeDataType> {
        var vertex = self.vertex(key)
        if vertex == nil {
            vertex = GraphVertex(key)
            self.vertexList.append(vertex!)
        }
        return vertex!
    }

    public func add_edge(_ sourceIndex: Int, _ neighborIndex: Int, _ data: EdgeDataType? = nil, _ weight: Int = 0) {
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
            edge!.data = data
            edge!.source.neighbors.append(edge!)
        }
        else {
            edge!.data = data
            edge!.weight = weight
        }
        if !self.isDirected {
            edge = self.edge(neighborIndex,sourceIndex)
            if edge == nil {
                edge = GraphEdge(neighbor!,source!,weight)
                edge!.data = data
                edge!.source.neighbors.append(edge!)
            }
            else {
                edge!.data = data
                edge!.weight = weight
            }
        }
    }

    public func remove_edge(_ sourceIndex: Int, _ neighborIndex: Int) {
        guard let source = self.vertex(sourceIndex) else {
            return
        }
        var newNeighbors:[GraphEdge<EdgeDataType,VertexDataType>] = []
        for edge in source.neighbors {
            if edge.neighbor.key != neighborIndex {
                newNeighbors.append(edge)
            }
        }
        source.neighbors = newNeighbors
        if !self.isDirected {
            guard let neighbor = self.vertex(neighborIndex) else {
                return
            }
            var newNeighbors:[GraphEdge<EdgeDataType,VertexDataType>] = []
            for edge in neighbor.neighbors {
                if edge.neighbor.key != sourceIndex {
                    newNeighbors.append(edge)
                }
            }
            neighbor.neighbors = newNeighbors
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

    //TODO Implement the reverse case
    public func topological_sort(reverse: Bool = false) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        var stack = Stack<GraphVertex<VertexDataType,EdgeDataType>>()
        var visited = Set<Int>()
        for vertex in self.vertexList {
            if !visited.contains(vertex.key) {
                Graph.topologicalSortUtil(vertex, &visited, &stack)
            }
        }
        var vertexList: [GraphVertex<VertexDataType,EdgeDataType>] = []
        while !stack.isEmpty {
            vertexList.append(stack.pop())
        }
        return vertexList
    }

    private class func topologicalSortUtil(_ vertex: GraphVertex<VertexDataType,EdgeDataType>,
                                           _ visited: inout Set<Int>,
                                           _ stack: inout Stack<GraphVertex<VertexDataType,EdgeDataType>>) {
        visited.update(with: vertex.key)
        for edge in vertex.neighbors {
            if !visited.contains(edge.neighbor.key) {
                self.topologicalSortUtil(edge.neighbor, &visited, &stack)
            }
        }
        stack.push(vertex)
    }

    public func predecessors(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        if self.vertex(key) == nil {
            return []
        }
        var list: [GraphVertex<VertexDataType,EdgeDataType>] = []
        for edge in self.edges {
            if edge.neighbor.key == key {
                list.append(edge.source)
            }
        }
        return list
    }

    public func ancestors(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        var list: [GraphVertex<VertexDataType,EdgeDataType>] = []
        var visited = Set<Int>()
        for vertex in self.vertexList {
            if vertex.key == key {
                continue
            }
            if visited.contains(vertex.key) {
                continue
            }
            _ = Graph.ancestorsUtil(vertex, key, &visited, &list)
        }
        return list
    }

    private class func ancestorsUtil(_ vertex: GraphVertex<VertexDataType,EdgeDataType>,
                                 _ key: Int,
                                 _ visited: inout Set<Int>,
                                 _ list: inout [GraphVertex<VertexDataType,EdgeDataType>]) -> Bool {
        visited.update(with: vertex.key)
        for edge in vertex.neighbors {
            if visited.contains(edge.neighbor.key) {
                continue
            }
            if edge.neighbor.key == key {
                list.append(vertex)
                return true
            }
            if Graph.ancestorsUtil(edge.neighbor, key, &visited, &list) {
                list.append(vertex)
                return true
            }
        }
        return false
    }

    public func nonAncestors(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        var vertexSet: Set<Int> = []
        for vertex in self.vertexList {
            vertexSet.update(with: vertex.key)
        }
        var ancestorsSet: Set<Int> = []
        for ancestor in self.ancestors(key) {
            ancestorsSet.update(with: ancestor.key)
        }
        let nonAncestorsSet = vertexSet.subtracting(ancestorsSet)
        var nonAncestorsList: [GraphVertex<VertexDataType,EdgeDataType>] = []
        for nonAncestor in nonAncestorsSet {
            nonAncestorsList.append(self.vertex(nonAncestor)!)
        }
        return nonAncestorsList
    }

    public func neighbors(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        guard let vertex = self.vertex(key) else {
            return []
        }
        var list: [GraphVertex<VertexDataType,EdgeDataType>] = []
        for edge in vertex.neighbors {
            list.append(edge.neighbor)
        }
        return list
    }

    public func successors(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        return self.neighbors(key)
    }

    public func descendants(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        guard let vertex = self.vertex(key) else {
            return []
        }
        var list: [GraphVertex<VertexDataType,EdgeDataType>] = []
        var visited = Set<Int>()
        for edge in vertex.neighbors {
            if !visited.contains(edge.neighbor.key) {
                Graph.descendantsUtil(edge.neighbor, &visited, &list)
            }
        }
        return list
    }

    private class func descendantsUtil(_ vertex: GraphVertex<VertexDataType,EdgeDataType>,
                                      _ visited: inout Set<Int>,
                                      _ list: inout [GraphVertex<VertexDataType,EdgeDataType>]) {
        list.append(vertex)
        visited.update(with: vertex.key)
        for edge in vertex.neighbors {
            if !visited.contains(edge.neighbor.key) {
                Graph.descendantsUtil(edge.neighbor, &visited, &list)
            }
        }
    }

    public func nonDescendants(_ key: Int) -> [GraphVertex<VertexDataType,EdgeDataType>] {
        var vertexSet: Set<Int> = []
        for vertex in self.vertexList {
            vertexSet.update(with: vertex.key)
        }
        var descendantsSet: Set<Int> = []
        for descendant in self.descendants(key) {
            descendantsSet.update(with: descendant.key)
        }
        let nonDescendantsSet = vertexSet.subtracting(descendantsSet)
        var nonDescendantsList: [GraphVertex<VertexDataType,EdgeDataType>] = []
        for nonDescendant in nonDescendantsSet {
            nonDescendantsList.append(self.vertex(nonDescendant)!)
        }
        return nonDescendantsList
    }

    // TODO implement
    public func order() -> Int {
        return 0
    }
    
    public func is_directed_acyclic_graph() -> Bool {
        return true
    }

    public func dag_longest_path_length() -> Int {
        return 0
    }

    public func number_weakly_connected_components() -> Int {
        return 0
    }
}
