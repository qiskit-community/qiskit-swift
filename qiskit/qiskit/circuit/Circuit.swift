//
//  Circuit.swift
//  qiskit
//
//  Created by Manoel Marques on 5/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public final class CircuitVertexData: NSCopying {
    public var name: HashableTuple<String,Int>
    public let type: String
    public var condition: HashableTuple<String,String>? = nil
    public var qargs: [HashableTuple<String,String>] = []
    public var cargs: [HashableTuple<String,String>] = []

    public init(_ name: HashableTuple<String,Int>, _ type: String) {
        self.name = name
        self.type = type
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = CircuitVertexData(self.name, self.type)
        copy.condition = self.condition
        copy.qargs = self.qargs
        copy.cargs = self.cargs
        return copy
    }
}

public final class CircuitEdgeData: NSCopying {
    public var name: HashableTuple<String,Int>

    public init(_ name: HashableTuple<String,Int>) {
        self.name = name
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return CircuitEdgeData(self.name)
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
public class Circuit: NSCopying {

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
    private var basis: [String: (Int,Int,Int)] = [:]

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
    private var gates: [String:[String:AnyObject]] = [:]

    /**
     Output precision for printing floats
    */
    private var prec = 10

    /**
     Create an empty circuit
     */
    public init() {

    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy =  Circuit()
        copy.wire_type = self.wire_type
        copy.input_map = self.input_map
        copy.output_map = self.output_map
        copy.node_counter = self.node_counter
        copy.basis = self.basis
        copy.multi_graph = self.multi_graph.copy(with: zone) as! Graph<CircuitVertexData,CircuitEdgeData>
        copy.qregs = self.qregs
        copy.cregs = self.cregs
        copy.gates = self.gates
        copy.prec = self.prec
        
        return copy
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
     Rename a classical or quantum register throughout the circuit.
     - parameter regname: existing register name string
     - parameter newname: replacement register name string
     */
    public func rename_register(_ regname: String, _ newname: String) throws {
        if regname == newname {
            return
        }
        if self.qregs[newname] != nil || self.cregs[newname] != nil {
            throw CircuitError.duplicateregister(name: newname)
        }
        if self.qregs[regname] == nil && self.cregs[regname] == nil {
            throw CircuitError.noregister(name: newname)
        }
        var reg_size: Int = 0
        if self.qregs[regname] != nil {
            self.qregs[newname] = self.qregs[regname]
            self.qregs.removeValue(forKey: regname)
            reg_size = self.qregs[newname]!
        }
        var iscreg = false
        if self.cregs[regname] != nil {
            self.cregs[newname] = self.cregs[regname]
            self.cregs.removeValue(forKey: regname)
            reg_size = self.cregs[newname]!
            iscreg = true
        }
        for i in 0..<reg_size {
            let oldTuple = HashableTuple<String,Int>(regname, i)
            let newTuple = HashableTuple<String,Int>(newname, i)
            self.wire_type[newTuple] = iscreg
            self.wire_type.removeValue(forKey: oldTuple)
            self.input_map[newTuple] = self.input_map[oldTuple]
            self.input_map.removeValue(forKey: oldTuple)
            self.output_map[newTuple] = self.output_map[oldTuple]
            self.output_map.removeValue(forKey: oldTuple)
        }
        // n node d = data
        for node in self.multi_graph.vertexList {
            guard let data = node.data else {
                continue
            }
            if data.type == "in" || data.type == "out" {
                if data.name.one == regname {
                    data.name = HashableTuple<String,Int>(newname, data.name.two)
                }
            }
            else if data.type == "op" {
                var qa: [HashableTuple<String,String>] = []
                for var a in data.qargs {
                    if a.one == regname {
                        a = HashableTuple<String,String>(newname, a.two)
                    }
                    qa.append(a)
                }
                data.qargs = qa
                var ca: [HashableTuple<String,String>] = []
                for var a in data.cargs {
                    if a.one == regname {
                        a = HashableTuple<String,String>(newname, a.two)
                    }
                    ca.append(a)
                }
                data.cargs = ca
                if let condition = data.condition {
                    if condition.one == regname {
                        data.condition  = HashableTuple<String,String>(newname, condition.two)
                    }
                }
            }
        }
        // eX = edge, d= data
        for edge in self.multi_graph.edges {
            guard let data = edge.data else {
                continue
            }
            if data.name.one == regname {
                data.name = HashableTuple<String,Int>(newname, data.name.two)
            }
        }
    }

    /**
     Remove all operation nodes with the given name
     */
    public func remove_all_ops_named(_ opname: String) throws {
        let nlist = try self.get_named_nodes(opname)
        for n in nlist {
            self._remove_op_node(n)
        }
    }

    /**
     Return a deep copy of self
     */
    public func deepcopy() -> Circuit {
        return self.copy(with: nil) as! Circuit
    }

    /**
     Format a float f as a string with self.prec digits.
     */
    public func fs(_ number: Double) -> String {
        let format = "%.\(self.prec)f"
        return String(format:format,number)
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

    /**
     Add an operation to the basis.
     name is string label for operation
     number_qubits is number of qubit arguments
     number_classical is number of bit arguments
     number_parameters is number of real parameters
     The parameters (nq,nc,np) are ignored for the special case
     when name = "barrier". The barrier instruction has a variable
     number of qubit arguments.
     */
    public func add_basis_element(_ name: String, _ number_qubits: Int, _ number_classical: Int = 0, _ number_parameters: Int = 0) throws {
        if self.basis[name] == nil {
            self.basis[name] = (number_qubits,number_classical,number_parameters)
        }
        if let gateMap = self.gates[name] {
            if number_classical != 0 {
                throw CircuitError.gatematch
            }
            if let nParameters = gateMap["n_args"] as? NSNumber {
                if nParameters.intValue != number_parameters {
                    throw CircuitError.gatematch
                }
            }
            if let nBits = gateMap["n_bits"] as? NSNumber {
                if nBits.intValue != number_qubits {
                    throw CircuitError.gatematch
                }
            }
        }
    }

    /**
     Add the definition of a gate.
     gatedata is dict with fields:
     "opaque" = True or False
     "n_args" = number of real parameters
     "n_bits" = number of qubits
     "args"   = list of parameter names
     "bits"   = list of qubit names
     "body"   = GateBody AST node
     */
    public func add_gate_data(_ name: String, _ gateMap: [String: AnyObject]) throws {
        if self.gates[name] == nil {
            self.gates[name] = gateMap
            if let basis = self.basis[name] {
                if let nBits = gateMap["n_bits"] as? NSNumber {
                    if nBits.intValue != basis.0 {
                        throw CircuitError.gatematch
                    }
                }
                if basis.1 != 0 {
                    throw CircuitError.gatematch
                }
                if let nParameters = gateMap["n_args"] as? NSNumber {
                    if nParameters.intValue != basis.2 {
                        throw CircuitError.gatematch
                    }
                }
            }
        }
    }

    /**
     Check the arguments against the data for this operation.
     name is a string
     qargs is a list of tuples like ("q",0)
     cargs is a list of tuples like ("c",0)
     params is a list of strings that represent floats
     */
    private func _check_basis_data(_ name: String, _ qargs: [(String,Int)], _ cargs: [(String,Int)], _ params: [String]) throws {
        // Check that we have this operation
        if self.basis[name] == nil {
            throw CircuitError.nobasicop(name: name)
        }
        // Check the number of arguments matches the signature
        if name != "barrier" {
            if let basis = self.basis[name] {
                if qargs.count != basis.0 {
                    throw CircuitError.qbitsnumber(name: name)
                }
                if cargs.count != basis.1 {
                    throw CircuitError.bitsnumber(name: name)
                }
                if params.count != basis.2 {
                    throw CircuitError.paramsnumber(name: name)
                }
            }
        }
        else {
            // "barrier" is a special case
            if qargs.isEmpty {
                throw CircuitError.qbitsnumber(name: name)
            }
            if !cargs.isEmpty {
                throw CircuitError.bitsnumber(name: name)
            }
            if !params.isEmpty {
                throw CircuitError.paramsnumber(name: name)
            }
        }
    }

    /**
     Verify that the condition is valid.
     name is a string used for error reporting
     condition is either None or a tuple (string,int) giving (creg,value)
     */
    private func _check_condition(_ name: String, _ cond: (String,Int)?) throws {
        // Verify creg exists
        if let condition = cond {
            if self.cregs[condition.0] != nil {
                throw CircuitError.cregcondition(name: name)
            }
        }
    }

    /**
     Check the values of a list of (qu)bit arguments.
     For each element A of args, check that amap contains A and
     self.wire_type[A] equals bval.
     args is a list of (regname,idx) tuples
     amap is a dictionary keyed on (regname,idx) tuples
     bval is boolean
     */
    private func _check_bits(_ args: [HashableTuple<String,Int>], amap: [HashableTuple<String,Int>:AnyObject], bval: Bool) throws {
        // Check for each wire
        for q in args {
            if amap[q] == nil {
                throw CircuitError.bitnotfound(q: q)
            }
            if let wt = self.wire_type[q] {
                if wt != bval {
                    throw CircuitError.wiretype(bVal: bval, q: q)
                }
            }
        }
    }

    /**
     Return a list of "op" nodes with the given name.
     */
    public func get_named_nodes(_ name: String) throws -> [Int] {
        if self.basis[name] == nil {
            throw CircuitError.nobasicop(name: name)
        }
        var nlist: [Int] = []
        // Iterate through the nodes of self in topological order
        let ts = self.multi_graph.topological_sort()
        for n in ts {
            if let nd = self.multi_graph.vertex(n) {
                if let data = nd.data {
                    if data.type == "op" && data.name.one == name {
                        nlist.append(n)
                    }
                }
            }
        }
        return nlist
    }

    /**
     Remove an operation node n.
     Add edges from predecessors to successors.
     */
    public func _remove_op_node(_ n: Int) {
        let (pred_map, succ_map) = self._make_pred_succ_maps(n)
        self.multi_graph.remove_vertex(n)
        for w in pred_map.keys {
            guard let predIndex = pred_map[w] else {
                continue
            }
            guard let succIndex = succ_map[w] else {
                continue
            }
            self.multi_graph.add_edge(predIndex, succIndex)
            if let edge = self.multi_graph.edge(predIndex,succIndex) {
                edge.data = CircuitEdgeData(w)
            }
        }
    }

    /**
     Return predecessor and successor dictionaries.
     These map from wire names to predecessor and successor
     nodes for the operation node n in self.multi_graph.
     */
    private func _make_pred_succ_maps(_ n: Int) -> ([HashableTuple<String,Int>:Int],[HashableTuple<String,Int>:Int]) {
        var pred_map: [HashableTuple<String,Int>:Int] = [:]
        var edges = self.multi_graph.in_edges_iter(n)
        for edge in edges {
            if let data = edge.data {
                pred_map[data.name] = edge.source.key
            }
        }
        var succ_map: [HashableTuple<String,Int>:Int] = [:]
        edges = self.multi_graph.out_edges_iter(n)
        for edge in edges {
            if let data = edge.data {
                succ_map[data.name] = edge.neighbor.key
            }
        }
        return (pred_map, succ_map)
    }
}
