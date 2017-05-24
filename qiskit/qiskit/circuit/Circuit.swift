//
//  Circuit.swift
//  qiskit
//
//  Created by Manoel Marques on 5/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public struct HashableTuple<A:Hashable,B:Hashable> : Hashable, Equatable {
    public let one: A
    public let two: B

    public init(_ one: A, _ two: B) {
        self.one = one
        self.two = two
    }
    public var hashValue : Int {
        get {
            return self.one.hashValue &* 31 &+ self.two.hashValue
        }
    }

    public static func ==<A:Hashable,B:Hashable>(lhs: HashableTuple<A,B>, rhs: HashableTuple<A,B>) -> Bool {
        return lhs.one == rhs.one && lhs.two == rhs.two
    }
}

public final class CircuitVertexData {
    public let name: HashableTuple<String,Int>
    public let type: String

    public init(_ name: HashableTuple<String,Int>, _ type: String) {
        self.name = name
        self.type = type
    }
}

public final class CircuitEdgeData {
    public let name: HashableTuple<String,Int>

    public init(_ name: HashableTuple<String,Int>) {
        self.name = name
    }
}

/**
 Object to represent a quantum circuit as a directed acyclic graph.
 The nodes in the graph are either input/output nodes or operation nodes.
 The operation nodes are elements of a basis that is part of the circuit.
 The QASM definitions of the basis elements are carried with the circuit.
 The edges correspond to qubits or bits in the circuit. A directed edge
 from node A to node B means that the (qu)bit passes from the output of A
 to the input of B. The object's methods allow circuits to be constructed,
 composed, and modified. Some natural properties like depth can be computed
 directly from the graph.
 */

/**
 Quantum circuit as a directed acyclic graph.
 There are 3 types of nodes in the graph: inputs, outputs, and operations.
 The nodes are connected by directed edges that correspond to qubits and
 bits.
 */
public class Circuit {

    /**
     Map from a wire's name (reg,idx) to a Bool that is True if the
     wire is a classical bit and False if the wire is a qubit.
    */
    private var wire_type: [HashableTuple<String,Int>:Bool] = [:]

    /**
     Map from wire names (reg,idx) to input nodes of the graph
    */
    private var input_map: [HashableTuple<String,Int>:Int] = [:]

    /**
     Map from wire names (reg,idx) to output nodes of the graph
    */
    private var output_map: [HashableTuple<String,Int>:Int] = [:]

    /**
     Running count of the total number of nodes
     */
    private var node_counter = 0

    /**
     Map of named operations in this circuit and their signatures.
     The signature is an integer tuple (nq,nc,np) specifying the
     number of input qubits, input bits, and real parameters.
     The definition is external to the circuit object.
    */
    //self.basis = {}

    /**
      Directed multigraph whose nodes are inputs, outputs, or operations.
      Operation nodes have equal in- and out-degrees and carry
      additional data about the operation, including the argument order
      and parameter values.
      Input nodes have out-degree 1 and output nodes have in-degree 1.
      Edges carry wire labels (reg,idx) and each operation has
      corresponding in- and out-edges with the same wire labels.
    */
    private var multi_graph:Graph<CircuitVertexData,CircuitEdgeData> = Graph<CircuitVertexData,CircuitEdgeData>(true)

    /**
      Map of qregs to sizes
    */
    private var qregs: [String:Int] = [:]

    /**
      Map of cregs to sizes
    */
    private var cregs: [String:Int] = [:]

    /**
     Map of user defined gates to ast nodes defining them
    */
    //self.gates = {}

    /**
     Output precision for printing floats
    */
    //self.prec = 10

    /**
     Create an empty circuit
     */
    public init() {

    }

    /**
     Return a list of qubits as (qreg, index) pairs.
     */
    public func get_qubits() -> [(String,Int)] {
        var array:[(String,Int)] = []
        for (name,index) in self.qregs {
            array.append((name,index))

        }
        return array
    }
    
    /**
     Add all wires in a quantum register named name with size.
     */
    public func add_qreg(_ name: String, _ size: Int) throws {
        if self.qregs[name] != nil || self.cregs[name] != nil {
            throw CircuitError.duplicateregister(name: name)
        }
        self.qregs[name] = size
        for j in 0..<size {
            try self._add_wire(HashableTuple<String,Int>(name, j))
        }
    }

    /**
     Add all wires in a classical register named name with size.
     */
    public func add_creg(_ name: String, _ size: Int) throws {
        if self.qregs[name] != nil || self.cregs[name] != nil {
            throw CircuitError.duplicateregister(name: name)
        }
        self.cregs[name] = size
        for j in 0..<size {
            try self._add_wire(HashableTuple<String,Int>(name, j), true)
        }
    }

    /**
    Add a qubit or bit to the circuit.
    name is a (string,int) tuple containing register name and index
    This adds a pair of in and out nodes connected by an edge.
     */
    private func _add_wire(_ name: HashableTuple<String,Int>, _ isClassical:Bool = false) throws {
        if self.wire_type[name] != nil {
            throw CircuitError.duplicatewire(tuple: name)
        }
        self.wire_type[name] = isClassical
        self.node_counter += 1
        self.input_map[name] = self.node_counter
        self.node_counter += 1
        self.output_map[name] = self.node_counter 
        let in_node: Int = self.input_map[name]!
        let out_node: Int = self.output_map[name]!
        self.multi_graph.add_edge(in_node, out_node)
        if let node = self.multi_graph.vertex(in_node) {
            node.data = CircuitVertexData(name,"in")
        }
        if let node = self.multi_graph.vertex(out_node) {
            node.data = CircuitVertexData(name,"out")
        }
        if let edge = self.multi_graph.edge(in_node,out_node) {
            edge.data = CircuitEdgeData(name)
        }
    }
}
