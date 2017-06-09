//
//  Unroller.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 OPENQASM interpreter object that unrolls subroutines and loops.
 */
final class Unroller {

    /**
     Abstract syntax tree from parser
     */
    private let ast: Node
    /**
     Backend object
     */
    private(set) var backend: UnrollerBackend?
    /**
     OPENQASM version number
     */
    private let version: Double = 0.0
    /**
     Dict of qreg names and sizes
     */
    private let qregs: [String:Int] = [:]
    /**
     Dict of creg names and sizes
    */
    private let cregs: [String:Int] = [:]
    /**
     Dict of gates names and properties
     */
    private var gates: [String:GateData] = [:]
    /**
     List of dictionaries mapping local parameter ids to real values
     */
    private var arg_stack: Stack<[String:Double]> = Stack<[String:Double]>()
    /**
     List of dictionaries mapping local bit ids to global ids (name,idx)
     */
    private var bit_stack: Stack<[String:RegBit]> = Stack<[String:RegBit]>()

    /**
     Initialize interpreter's data.
     */
    init(_ ast: Node, _ backend: UnrollerBackend? = nil) {
        self.ast = ast
        self.backend = backend
    }

    /**
     Process an Id or IndexedId node as a bit or register type.
     Return a list of tuples (name,index).
     */
    private func _process_bit_id(_ node: Node) throws -> [RegBit] {
        if node.type == .N_INDEXEDID {
            // An indexed bit or qubit
            return [RegBit(node.name, node.index)]
        }
        if node.type == .N_ID {
            // A qubit or qreg or creg
            var bits: [String:RegBit] = [:]
            if let map = self.bit_stack.peek() {
                bits = map
            }
            if bits.isEmpty {
                // Global scope
                if let size = self.qregs[node.name] {
                    var array: [RegBit] = []
                    for j in 0..<size {
                        array.append(RegBit(node.name,j))
                    }
                    return array
                }
                if let size = self.cregs[node.name] {
                    var array: [RegBit] = []
                    for j in 0..<size {
                        array.append(RegBit(node.name,j))
                    }
                    return array
                }
                throw UnrollerException.errorregname(line: node.line,file: node.file)
            }
            // local scope
            if let regBit = bits[node.name] {
                return [regBit]
            }
            throw UnrollerException.errorlocalbit(line: node.line,file: node.file)
        }
        return []
    }

    /**
     Process an Id node as a local id.
     */
    private func _process_local_id(_ node: Node) throws -> Double {
        // The id must be in arg_stack i.e. the id is inside a gate_body
        var id_dict: [String:Double] = [:]
        if let map = self.arg_stack.peek() {
            id_dict = map
        }
        if let value = id_dict[node.name] {
            return value
        }
        throw UnrollerException.errorlocalparameter(line: node.line,file: node.file)
    }

    /**
     Process a custom unitary node.
     */
    private func _process_custom_unitary(_ node: Node) throws {
        let name = node.name
        var args: [Double] = []
        if let arguments = node.arguments {
            args = try self._process_node(arguments)
        }
        var bits: [[RegBit]] = []
        let children = node.bitlist?.children ?? []
        for node_element in children {
            bits.append(try self._process_bit_id(node_element))
        }
        if let gate = self.gates[name] {
            let gargs = gate.args
            let gbits = gate.bits
            let gbody = gate.body
            // Loop over register arguments, if any.
            var maxidx: Int = 0
            for bitList in bits {
                if maxidx < bitList.count {
                    maxidx = bitList.count
                }
            }
            for idx in 0..<maxidx {
                var map: [String:Double] = [:]
                for j in 0..<gargs.count {
                    map[gargs[j]] = args[j]
                }
                self.arg_stack.push(map)
                // Only index into register arguments.
                var element: [Int] = []
                for j in 0..<bits.count {
                    if bits[j].count > 1 {
                        element.append(idx * j)
                    }
                }
                for j in 0..<gbits.count {
                    self.bit_stack.push([gbits[j] : bits[j][element[j]]])
                }
                var args: [Double] = []
                if let map = self.arg_stack.peek() {
                    for s in gargs {
                        if let value = map[s] {
                            args.append(value)
                        }
                    }
                }
                 var qubits: [RegBit] = []
                if let map = self.bit_stack.peek() {
                    for s in gbits {
                        if let value = map[s] {
                            qubits.append(value)
                        }
                    }
                }
                if let backend = self.backend {
                    try backend.start_gate(name,args,qubits)
                }
                if !gate.opaque && gbody != nil {
                    try self._process_children(gbody!)
                }
                if let backend = self.backend {
                    backend.end_gate(name,args,qubits)
                }
                _ = self.arg_stack.pop()
                _ = self.bit_stack.pop()
            }
            return
        }
        throw UnrollerException.errorundefinedgate(line: node.line, file:node.file)
    }

    /**
     Process a gate node.
     If opaque is True, process the node as an opaque gate node.
     */
    private func _process_gate(_ node: Node, _ opaque: Bool = false) throws {
        let opaque = opaque
        let n_args = node.n_args
        let n_bits = node.n_bits
        var args: [String] = []
        if node.n_args > 0 {
            for element in node.arguments!.children {
                args.append(element.name)
            }
        }
        var bits: [String] = []
        let children = node.bitlist?.children ?? []
        for c in children {
            bits.append(c.name)
        }
        let body: Node? = (opaque) ? nil : node.body
        let gate = GateData(opaque,n_args,n_bits,args,bits,body)
        self.gates[node.name] = gate
        if let backend = self.backend {
            try backend.define_gate(node.name, gate.copy(with: nil) as! GateData)
        }
    }

    /**
     Call process_node for all children of node.
     */
    private func _process_children(_ node: Node) throws {
        for c in node.children {
            _ = try self._process_node(c)
        }
    }

    /**
     Carry out the action associated with node n.
     */
    private func _process_node(_ node: Node) throws -> [Double] {
        preconditionFailure("_process_node not implemented")
    }

    /**
     Set the backend object
     */
    func set_backend(_ backend: UnrollerBackend?) {
        self.backend = backend
    }

    /**
     Interpret OPENQASM and make appropriate backend calls.
     */
    func execute() throws {
        if self.backend != nil {
            _ = try self._process_node(self.ast)
        }
        throw UnrollerException.errorbackend
    }
}
