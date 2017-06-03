//
//  Graph.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

enum SearchProcessType {
    case vertexEarly
    case vertexLate
    case edge
}

enum EdgeClassification {
    case tree
    case back
    case forward
    case cross
    case unknown
}

final class BFSState {
    fileprivate(set) var discovered: Set<Int> = []
    fileprivate(set) var processed: Set<Int> = []
    fileprivate(set) var parent: [Int:Int] = [:]
}

typealias BFSHandler<VertexDataType: NSCopying,EdgeDataType: NSCopying> = (SearchProcessType,
                        GraphVertex<VertexDataType>?,
                        GraphEdge<EdgeDataType>?,
                        BFSState) throws -> (Void)

final class DFSState {
    var finished = false
    fileprivate var queue: [Int] = []
    fileprivate(set) var discovered: Set<Int> = []
    fileprivate(set) var processed: Set<Int> = []
    fileprivate(set) var time: Int = 0
    fileprivate(set) var entryTime: [Int:Int] = [:]
    fileprivate(set) var exitTime: [Int:Int] = [:]
    fileprivate(set) var parent: [Int:Int] = [:]
}

typealias DFSHandler<VertexDataType: NSCopying,EdgeDataType: NSCopying> = (SearchProcessType,
                                                        GraphVertex<VertexDataType>?,
                                                        GraphEdge<EdgeDataType>?,
                                                        DFSState) throws -> (Void)

final class Graph<VertexDataType: NSCopying,EdgeDataType: NSCopying>: NSCopying {

    public private(set) var vertices: OrderedDictionary<Int,GraphVertex<VertexDataType>> =
                                                OrderedDictionary<Int,GraphVertex<VertexDataType>>()
    public private(set) var edges: OrderedDictionary<HashableTuple<Int,Int>,GraphEdge<EdgeDataType>> =
                                                OrderedDictionary<HashableTuple<Int,Int>,GraphEdge<EdgeDataType>>()
    public let isDirected: Bool

    public init(_ isDirected: Bool) {
        self.isDirected = isDirected
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Graph(self.isDirected)
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i).copy(with: zone) as! GraphVertex<VertexDataType>
            copy.vertices[vertex.key] = vertex
        }
        for i in 0..<self.edges.count {
            let edge = self.edges.value(i).copy(with: zone) as! GraphEdge<EdgeDataType>
            copy.edges[HashableTuple<Int,Int>(edge.source,edge.neighbor)] = edge
        }
        return copy
    }

    public func vertex(_ key: Int) -> GraphVertex<VertexDataType>? {
        return self.vertices[key]
    }

    public func edge(_ sourceIndex: Int, _ neighborIndex: Int) -> GraphEdge<EdgeDataType>? {
        return self.edges[HashableTuple<Int,Int>(sourceIndex,neighborIndex)]
    }

    public func add_vertex(_ key: Int) -> GraphVertex<VertexDataType> {
        var vertex = self.vertex(key)
        if vertex == nil {
            vertex = GraphVertex(key)
            self.vertices[key] = vertex!
        }
        return vertex!
    }

    public func add_edge(_ sourceIndex: Int, _ neighborIndex: Int, _ data: EdgeDataType? = nil) {
        let source = self.add_vertex(sourceIndex)
        let neighbor = self.add_vertex(neighborIndex)
        var edge = self.edge(source.key,neighbor.key)
        if edge == nil {
            edge = GraphEdge(source.key,neighbor.key)
            edge!.data = data
            source.neighbors[neighbor.key] = neighbor
            self.edges[HashableTuple<Int,Int>(sourceIndex,neighborIndex)] = edge!
        }
        else {
            edge!.data = data
        }
        if !self.isDirected {
            edge = self.edge(neighbor.key,source.key)
            if edge == nil {
                edge = GraphEdge(neighbor.key,source.key)
                edge!.data = data
                neighbor.neighbors[source.key] = source
                self.edges[HashableTuple<Int,Int>(neighborIndex,sourceIndex)] = edge!
            }
            else {
                edge!.data = data
            }
        }
    }

    public func remove_edge(_ sourceIndex: Int, _ neighborIndex: Int) {
        self.edges[HashableTuple<Int,Int>(sourceIndex,neighborIndex)] = nil
        if let source = self.vertex(sourceIndex) {
            source.neighbors[neighborIndex] = nil
        }
        if !self.isDirected {
            self.edges[HashableTuple<Int,Int>(neighborIndex,sourceIndex)] = nil
            if let neighbor = self.vertex(neighborIndex) {
                neighbor.neighbors[sourceIndex] = nil
            }
        }
    }

    public func remove_vertex(_ index: Int) {
        if self.vertex(index) == nil {
            return
        }
        self.edges[HashableTuple<Int,Int>(index,index)] = nil
        self.vertices[index] = nil
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
            vertex.neighbors[index] = nil
            self.edges[HashableTuple<Int,Int>(index,vertex.key)] = nil
            self.edges[HashableTuple<Int,Int>(vertex.key,index)] = nil
        }
    }

    public func in_edges_iter(_ index: Int) -> [GraphEdge<EdgeDataType>] {
        if self.vertex(index) == nil {
            return []
        }
        var inEdges: [GraphEdge<EdgeDataType>] = []
        for i in 0..<self.edges.count {
            let edge = self.edges.value(i)
            if edge.neighbor == index {
                inEdges.append(edge)
            }
        }
        return inEdges
    }

    public func out_edges_iter(_ index: Int) -> [GraphEdge<EdgeDataType>] {
        if self.vertex(index) == nil {
            return []
        }
        var outEdges: [GraphEdge<EdgeDataType>] = []
        for i in 0..<self.edges.count {
            let edge = self.edges.value(i)
            if edge.source == index {
                outEdges.append(edge)
            }
        }
        return outEdges
    }

    public func bfs(_ start:  GraphVertex<VertexDataType>,
                    _ state:   BFSState,
                    _ handler: BFSHandler<VertexDataType,EdgeDataType>) throws {
        var queue = Queue<GraphVertex<VertexDataType>>()
        queue.enqueue(start)
        state.discovered.update(with: start.key)
        while !queue.isEmpty {
            let vertex = queue.dequeue()
            try handler(SearchProcessType.vertexEarly,vertex,nil,state)
            for i in 0..<vertex.neighbors.count {
                let neighbor = vertex.neighbors.value(i)
                let edge = self.edge(vertex.key,neighbor.key)
                try handler(SearchProcessType.edge,nil,edge,state)
                if !state.discovered.contains(neighbor.key) {
                    state.discovered.update(with: neighbor.key)
                    state.parent[neighbor.key] = vertex.key
                    queue.enqueue(neighbor)
                }
            }
            state.processed.update(with: vertex.key)
            try handler(SearchProcessType.vertexLate,vertex,nil,state)
        }
    }

    public func dfs(_ vertex:  GraphVertex<VertexDataType>,
                           _ state:   DFSState,
                           _ handler: DFSHandler<VertexDataType,EdgeDataType>) throws {

        if state.finished {
            return
        }
        state.discovered.update(with: vertex.key)
        state.time += 1
        state.entryTime[vertex.key] = state.time
        try handler(SearchProcessType.vertexEarly,vertex,nil,state)
        for i in 0..<vertex.neighbors.count {
            let neighbor = vertex.neighbors.value(i)
            let edge = self.edge(vertex.key,neighbor.key)
            if !state.discovered.contains(neighbor.key) {
                state.parent[neighbor.key] = vertex.key
                try handler(SearchProcessType.edge,nil,edge,state)
                try self.dfs(neighbor, state, handler)
                if state.finished {
                    return
                }
            }
        }
        try handler(SearchProcessType.vertexLate,vertex,nil,state)
        state.time += 1
        state.exitTime[vertex.key] = state.time
        state.processed.update(with: vertex.key)
    }

    public static func edgeClassification(_ edge: GraphEdge<EdgeDataType>,
                                          _ state: DFSState) -> EdgeClassification {
        if let parent = state.parent[edge.neighbor] {
            if parent == edge.source {
                return EdgeClassification.tree
            }
        }
        if state.discovered.contains(edge.neighbor) &&
            !state.processed.contains(edge.neighbor) {
            return EdgeClassification.back
        }
        if state.processed.contains(edge.neighbor) {
            var entryTimeSource = 0
            if let time = state.entryTime[edge.source] {
                entryTimeSource = time
            }
            var entryTimeNeighbor = 0
            if let time = state.entryTime[edge.neighbor] {
                entryTimeNeighbor = time
            }
            if entryTimeNeighbor > entryTimeSource {
                return EdgeClassification.forward
            }
            if entryTimeNeighbor < entryTimeSource {
                return EdgeClassification.cross
            }
        }
        return EdgeClassification.unknown
    }

    public func topological_sort(reverse: Bool = false) throws -> [GraphVertex<VertexDataType>] {
        if !self.isDirected {
            throw GraphError.isUndirected
        }
        let state: DFSState = DFSState()
        var queue = Queue<GraphVertex<VertexDataType>>()
        var stack = Stack<GraphVertex<VertexDataType>>()
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
            if !state.discovered.contains(vertex.key) {
                try dfs(vertex, state) { (searchProcessType,vertex,edge,state) -> Void in
                    if searchProcessType == SearchProcessType.vertexLate {
                        stack.push(vertex!)
                        queue.enqueue(vertex!)
                        return
                    }
                    if searchProcessType == SearchProcessType.edge {
                        let classification = Graph.edgeClassification(edge!,state)
                        if classification == EdgeClassification.back {
                            throw GraphError.isCyclic
                        }
                    }
                }
            }
        }
        var vertices: [GraphVertex<VertexDataType>] = []
        if reverse {
            while !queue.isEmpty {
                vertices.append(queue.dequeue())
            }
        }
        else {
            while !stack.isEmpty {
                vertices.append(stack.pop())
            }
        }
        return vertices
    }

    public func predecessors(_ key: Int) -> [GraphVertex<VertexDataType>] {
        if self.vertex(key) == nil {
            return []
        }
        var list: [GraphVertex<VertexDataType>] = []
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
            for j in 0..<vertex.neighbors.count {
                let neighbor = vertex.neighbors.value(j)
                if neighbor.key == key {
                    list.append(vertex)
                }
            }
        }
        return list
    }

    public func ancestors(_ key: Int) -> [GraphVertex<VertexDataType>] {
        var list: [GraphVertex<VertexDataType>] = []
        var visited = Set<Int>()
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
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

    private class func ancestorsUtil(_ vertex: GraphVertex<VertexDataType>,
                                 _ key: Int,
                                 _ visited: inout Set<Int>,
                                 _ list: inout [GraphVertex<VertexDataType>]) -> Bool {
        visited.update(with: vertex.key)
        for i in 0..<vertex.neighbors.count {
            let neighbor = vertex.neighbors.value(i)
            if visited.contains(neighbor.key) {
                continue
            }
            if neighbor.key == key {
                list.append(vertex)
                return true
            }
            if Graph.ancestorsUtil(neighbor, key, &visited, &list) {
                list.append(vertex)
                return true
            }
        }
        return false
    }

    public func nonAncestors(_ key: Int) -> [GraphVertex<VertexDataType>] {
        var vertexSet: Set<Int> = []
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
            vertexSet.update(with: vertex.key)
        }
        var ancestorsSet: Set<Int> = []
        for ancestor in self.ancestors(key) {
            ancestorsSet.update(with: ancestor.key)
        }
        let nonAncestorsSet = vertexSet.subtracting(ancestorsSet)
        var nonAncestorsList: [GraphVertex<VertexDataType>] = []
        for nonAncestor in nonAncestorsSet {
            nonAncestorsList.append(self.vertex(nonAncestor)!)
        }
        return nonAncestorsList
    }

    public func neighbors(_ key: Int) -> [GraphVertex<VertexDataType>] {
        guard let vertex = self.vertex(key) else {
            return []
        }
        var list: [GraphVertex<VertexDataType>] = []
        for i in 0..<vertex.neighbors.count {
            list.append(vertex.neighbors.value(i))
        }
        return list
    }

    public func successors(_ key: Int) -> [GraphVertex<VertexDataType>] {
        return self.neighbors(key)
    }

    public func descendants(_ key: Int) -> [GraphVertex<VertexDataType>] {
        guard let vertex = self.vertex(key) else {
            return []
        }
        var list: [GraphVertex<VertexDataType>] = []
        var visited = Set<Int>()
        for i in 0..<vertex.neighbors.count {
            let neighbor = vertex.neighbors.value(i)
            if !visited.contains(neighbor.key) {
                Graph.descendantsUtil(neighbor, &visited, &list)
            }
        }
        return list
    }

    private class func descendantsUtil(_ vertex: GraphVertex<VertexDataType>,
                                      _ visited: inout Set<Int>,
                                      _ list: inout [GraphVertex<VertexDataType>]) {
        list.append(vertex)
        visited.update(with: vertex.key)
        for i in 0..<vertex.neighbors.count {
            let neighbor = vertex.neighbors.value(i)
            if !visited.contains(neighbor.key) {
                Graph.descendantsUtil(neighbor, &visited, &list)
            }
        }
    }

    public func nonDescendants(_ key: Int) -> [GraphVertex<VertexDataType>] {
        var vertexSet: Set<Int> = []
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
            vertexSet.update(with: vertex.key)
        }
        var descendantsSet: Set<Int> = []
        for descendant in self.descendants(key) {
            descendantsSet.update(with: descendant.key)
        }
        let nonDescendantsSet = vertexSet.subtracting(descendantsSet)
        var nonDescendantsList: [GraphVertex<VertexDataType>] = []
        for nonDescendant in nonDescendantsSet {
            nonDescendantsList.append(self.vertex(nonDescendant)!)
        }
        return nonDescendantsList
    }

    public func order() -> Int {
        return self.vertices.count
    }
    
    public func is_directed_acyclic_graph() -> Bool {
        if !self.isDirected {
            return false
        }
        let state: DFSState = DFSState()
        for i in 0..<self.vertices.count {
            let vertex = self.vertices.value(i)
            if !state.discovered.contains(vertex.key) {
                do {
                    try self.dfs(vertex, state) { (searchProcessType,vertex,edge,state) -> Void in
                        if searchProcessType == SearchProcessType.edge {
                            let classification = Graph.edgeClassification(edge!,state)
                            if classification == EdgeClassification.back {
                                throw GraphError.isCyclic
                            }
                        }
                    }
                }
                catch GraphError.isCyclic {
                    return false
                }
                catch {
                    return false
                }
            }
        }
        return true
    }

    // TODO implement
    public func dag_longest_path_length() throws -> Int {
        if !self.isDirected {
            throw GraphError.isUndirected
        }
        return 0
    }

    // TODO implement
    public func number_weakly_connected_components() throws -> Int {
        if !self.isDirected {
            throw GraphError.isUndirected
        }
        return 0
    }
}
