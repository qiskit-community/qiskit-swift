//
//  Coupling.swift
//  qiskit
//
//  Created by Manoel Marques on 6/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Directed graph object for representing coupling between qubits.
 The nodes of the graph correspond to named qubits and the directed edges
 indicate which qubits are coupled and the permitted direction of CNOT gates.
 The object has a distance function that can be used to map quantum circuits
 onto a device with this coupling.
 */
final class Coupling: CustomStringConvertible {

    /**
    qubits is dict from qubit (regname,idx) tuples to node indices
     */
    private var qubits: [RegBit:GraphVertex<CouplingVertexData>] = [:]

    /**
     index_to_qubit is a dict from node indices to qubits
     */
    private var index_to_qubit: [GraphVertex<CouplingVertexData>:RegBit] = [:]

    /**
     node_counter is integer counter for labeling nodes
     */
    private var node_counter = 0

    /**
     G is the coupling digraph
     */
    private var G: Graph<CouplingVertexData,NSString> = Graph<CouplingVertexData,NSString>(directed: true)

    /**
     dist is a dict of dicts from node pairs to distances
     it must be computed, it is the distance on the digraph
     */
    private var dist: [RegBit:[RegBit:Int]] = [:]

    /**
     Return a string representation of the coupling graph.
     */
    public var description: String {
        var s = "qubits: "
        var list: [String] = []
        for (k,v) in self.qubits    {
            list.append("\(k.description) @ \(v.key)")
        }
        s += list.joined(separator: ", ")
        s += "\nedges: "
        list = []
        for tuple in self.get_edges() {
            list.append("\(tuple.one.description)-\(tuple.two.description)")
        }
        s += list.joined(separator: ", ")
        return s
    }

    /**
     Directed graph specifying fixed coupling.
     Nodes correspond to qubits and directed edges correspond to permitted
     CNOT gates
     */
    /**
     Create coupling graph.
     By default, the coupling graph has no nodes. The optional couplingdict
     specifies the graph as an adjacency list. For example,
     couplingdict = {0: [1, 2], 1: [2]}.
     */
    init(_ couplingdict: [Int:[Int]]? = nil) throws {
        // Add edges to the graph if the couplingdict is present
        if let dict = couplingdict {
            for (v0, alist) in dict {
                for v1 in alist {
                    let regname = "q"
                    try self.add_edge(RegBit(regname, v0), RegBit(regname, v1))
                }
            }
            try self.compute_distance()
        }
    }

    /**
     Return the number of qubits in this graph
     */
    public func size() -> Int {
        return self.qubits.count
    }

    /**
     Return the qubits in this graph as (qreg, index) tuples
     */
    public func get_qubits() -> [RegBit] {
        return Array<RegBit>(self.qubits.keys)
    }

    /**
     Return a list of edges in the coupling graph.
     Each edge is a pair of qubits and each qubit is a tuple (qreg, index).
     */
    public func get_edges() -> Set<HashableTuple<RegBit,RegBit>> {
        var edges: Set<HashableTuple<RegBit,RegBit>> = Set<HashableTuple<RegBit,RegBit>>()
        for i in 0..<self.G.edges.count {
            let edge = self.G.edges.value(i)
            guard let source = self.G.vertex(edge.source) else {
                continue
            }
            guard let qubitSource = self.index_to_qubit[source] else {
                continue
            }
            guard let neighbor = self.G.vertex(edge.neighbor) else {
                continue
            }
            guard let qubitNeighbor = self.index_to_qubit[neighbor] else {
                continue
            }
            edges.update(with: HashableTuple<RegBit,RegBit>(qubitSource,qubitNeighbor))
        }
        return edges
    }

    /**
     Add a qubit to the coupling graph.
     name = tuple (regname, idx) for qubit
     */
    public func add_qubit(_ name: RegBit) throws {
        if self.qubits[name] != nil {
            throw CouplingError.duplicateregbit(regBit: name)
        }
        self.node_counter += 1
        self.qubits[name] = self.G.add_vertex(self.node_counter, CouplingVertexData(name))
        self.index_to_qubit[self.qubits[name]!] = name
    }

    /**
     Add directed edge to coupling graph.
     s_name = source qubit tuple
     d_name = destination qubit tuple
     */
    public func add_edge(_ s_name: RegBit, _ d_name: RegBit) throws {
        if self.qubits[s_name] == nil {
            try self.add_qubit(s_name)
        }
        if self.qubits[d_name] == nil {
            try self.add_qubit(d_name)
        }
        self.G.add_edge(self.qubits[s_name]!, self.qubits[d_name]!)
    }

    /**
     Test if the graph is connected.
     Return True if connected, False otherwise
     */
    public func connected() throws -> Bool {
        return try self.G.is_weakly_connected()
    }

    /**
     Compute the distance function on pairs of nodes.
     The distance map self.dist is computed from the graph using
     all_pairs_shortest_path_length    
    */
    public func compute_distance() throws {
        if try !self.connected() {
            throw CouplingError.notconnected
        }
        let lengths = self.G.to_undirected().all_pairs_shortest_path_length()
        self.dist = [:]
        for (i,_) in self.qubits {
            self.dist[i] = [:]
            guard let sourceVertex = self.qubits[i] else {
                continue
            }
            guard let lengthSource = lengths[sourceVertex] else {
                continue
            }
            for (j,_) in self.qubits {
                guard let endVertex = self.qubits[j] else {
                    continue
                }
                guard let lengthEnd = lengthSource[endVertex] else {
                    continue
                }
                self.dist[i]![j] = lengthEnd
            }
        }
    }

    /**
     Return the distance between qubit q1 to qubit q2
     */
    public func distance(_ q1: RegBit, _ q2: RegBit) throws -> Int {
        if self.dist.isEmpty {
            throw CouplingError.distancenotcomputed
        }
        if self.qubits[q1] == nil {
            throw CouplingError.notincouplinggraph(regBit: q1)
        }
        if self.qubits[q2] == nil {
            throw CouplingError.notincouplinggraph(regBit: q2)
        }
        guard let distMap = self.dist[q1] else {
            return 0
        }
        guard let distance = distMap[q2] else {
            return 0
        }
        return distance
    }
}
