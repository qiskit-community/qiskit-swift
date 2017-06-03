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
                        GraphVertex<VertexDataType,EdgeDataType>?,
                        GraphEdge<EdgeDataType,VertexDataType>?,
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
                                                        GraphVertex<VertexDataType,EdgeDataType>?,
                                                        GraphEdge<EdgeDataType,VertexDataType>?,
                                                        DFSState) throws -> (Void)

final class Graph<VertexDataType: NSCopying,EdgeDataType: NSCopying>: NSCopying {

    public private(set) var vertices: [GraphVertex<VertexDataType,EdgeDataType>] = []
    public let isDirected: Bool

    public var edges: [GraphEdge<EdgeDataType,VertexDataType>] {
        var edges: [GraphEdge<EdgeDataType,VertexDataType>] = []
        for vertex in self.vertices {
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
        for vertex in self.vertices {
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
            copy.add_edge(edge.source.key, edge.neighbor.key, d)
        }
        return copy
    }

    public func vertex(_ key: Int) -> GraphVertex<VertexDataType,EdgeDataType>? {
        for vertex in self.vertices {
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
            self.vertices.append(vertex!)
        }
        return vertex!
    }

    public func add_edge(_ sourceIndex: Int, _ neighborIndex: Int, _ data: EdgeDataType? = nil) {
        var source = self.vertex(sourceIndex)
        if source == nil {
            source = GraphVertex(sourceIndex)
            self.vertices.append(source!)
        }
        var neighbor = self.vertex(neighborIndex)
        if neighbor == nil {
            neighbor = GraphVertex(neighborIndex)
            self.vertices.append(neighbor!)
        }
        var edge = self.edge(sourceIndex,neighborIndex)
        if edge == nil {
            edge = GraphEdge(source!,neighbor!)
            edge!.data = data
            edge!.source.neighbors.append(edge!)
        }
        else {
            edge!.data = data
        }
        if !self.isDirected {
            edge = self.edge(neighborIndex,sourceIndex)
            if edge == nil {
                edge = GraphEdge(neighbor!,source!)
                edge!.data = data
                edge!.source.neighbors.append(edge!)
            }
            else {
                edge!.data = data
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
        var newvertices: [GraphVertex<VertexDataType,EdgeDataType>] = []
        for vertex in self.vertices {
            if vertex.key != index {
                newvertices.append(vertex)
                var newNeighborList: [GraphEdge<EdgeDataType,VertexDataType>] = []
                for edge in vertex.neighbors {
                    if edge.neighbor.key != index {
                        newNeighborList.append(edge)
                    }
                }
                vertex.neighbors = newNeighborList
            }
        }
        self.vertices = newvertices
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

    public static func bfs(_ start:  GraphVertex<VertexDataType,EdgeDataType>,
                           _ state:   BFSState,
                           _ handler: BFSHandler<VertexDataType,EdgeDataType>) throws {
        var queue = Queue<GraphVertex<VertexDataType,EdgeDataType>>()
        queue.enqueue(start)
        state.discovered.update(with: start.key)
        while !queue.isEmpty {
            let vertex = queue.dequeue()
            try handler(SearchProcessType.vertexEarly,vertex,nil,state)
            for edge in vertex.neighbors {
                let neighbor = edge.neighbor
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

    public static func dfs(_ vertex:  GraphVertex<VertexDataType,EdgeDataType>,
                           _ state:   DFSState,
                           _ handler: DFSHandler<VertexDataType,EdgeDataType>) throws {

        if state.finished {
            return
        }
        state.discovered.update(with: vertex.key)
        state.time += 1
        state.entryTime[vertex.key] = state.time
        try handler(SearchProcessType.vertexEarly,vertex,nil,state)
        for edge in vertex.neighbors {
            let neighbor = edge.neighbor
            if !state.discovered.contains(neighbor.key) {
                state.parent[neighbor.key] = vertex.key
                try handler(SearchProcessType.edge,nil,edge,state)
                try Graph.dfs(neighbor, state, handler)
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

    public static func edgeClassification(_ edge: GraphEdge<EdgeDataType,VertexDataType>,
                                          _ state: DFSState) -> EdgeClassification {
        if let parent = state.parent[edge.neighbor.key] {
            if parent == edge.source.key {
                return EdgeClassification.tree
            }
        }
        if state.discovered.contains(edge.neighbor.key) &&
            !state.processed.contains(edge.neighbor.key) {
            return EdgeClassification.back
        }
        if state.processed.contains(edge.neighbor.key) {
            var entryTimeSource = 0
            if let time = state.entryTime[edge.source.key] {
                entryTimeSource = time
            }
            var entryTimeNeighbor = 0
            if let time = state.entryTime[edge.neighbor.key] {
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

    public func topological_sort(reverse: Bool = false) throws -> [GraphVertex<VertexDataType,EdgeDataType>] {
        if !self.isDirected {
            throw GraphError.isUndirected
        }
        let state: DFSState = DFSState()
        var queue = Queue<GraphVertex<VertexDataType,EdgeDataType>>()
        var stack = Stack<GraphVertex<VertexDataType,EdgeDataType>>()
        for vertex in self.vertices {
            if !state.discovered.contains(vertex.key) {
                try Graph.dfs(vertex, state) { (searchProcessType,vertex,edge,state) -> Void in
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
        var vertices: [GraphVertex<VertexDataType,EdgeDataType>] = []
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
        for vertex in self.vertices {
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
        for vertex in self.vertices {
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
        for vertex in self.vertices {
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

    public func order() -> Int {
        return self.vertices.count
    }
    
    public func is_directed_acyclic_graph() -> Bool {
        if !self.isDirected {
            return false
        }
        let state: DFSState = DFSState()
        for vertex in self.vertices {
            if !state.discovered.contains(vertex.key) {
                do {
                    try Graph.dfs(vertex, state) { (searchProcessType,vertex,edge,state) -> Void in
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
