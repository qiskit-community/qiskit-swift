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
    private var version: Double = 0.0
    /**
     Dict of qreg names and sizes
     */
    private var qregs: [String:Int] = [:]
    /**
     Dict of creg names and sizes
    */
    private var cregs: [String:Int] = [:]
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
    private func _process_local_id(_ node: NodeId) throws -> Double {
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
    private func _process_gate(_ node: NodeGate, opaque: Bool = false) throws {
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
     Process a CNOT gate node.
     */
    private func _process_cnot(_ node: NodeCnot) throws {
        let id0 = try self._process_bit_id(node.children[0])
        let id1 = try self._process_bit_id(node.children[1])
        if !(id0.count == id1.count || id0.count == 1 || id1.count == 1) {
            throw UnrollerException.errorqregsize(line: node.line, file: node.file)
        }
        let maxidx = max(id0.count, id1.count)
        if let backend = self.backend {
            for idx in 0..<maxidx {
                if id0.count > 1 && id1.count > 1 {
                    try backend.cx(id0[idx], id1[idx])
                    continue
                }
                if id0.count > 1 {
                    try backend.cx(id0[idx], id1[0])
                    continue
                }
                try backend.cx(id0[0], id1[idx])
            }
        }
    }

    /**
     Process a binary operation node.
     */
    private func _process_binop(_ node: NodeBinaryOp) throws -> Double {
        let operation = node.op
        let lexpr = node.children[1]
        let rexpr = node.children[2]
        if operation == "+" {
            return try self._process_node(lexpr)[0] + self._process_node(rexpr)[0]
        }
        if operation == "-" {
            return try self._process_node(lexpr)[0] - self._process_node(rexpr)[0]
        }
        if operation == "*" {
            return try self._process_node(lexpr)[0] * self._process_node(rexpr)[0]
        }
        if operation == "/" {
            return try self._process_node(lexpr)[0] / self._process_node(rexpr)[0]
        }
        if operation == "^" {
            return try pow(self._process_node(lexpr)[0],self._process_node(rexpr)[0])
        }
        throw UnrollerException.errorbinop(line: node.line, file: node.file)
    }

    /**
     Process a prefix node.
     */
    private func _process_prefix(_ node: NodePrefix) throws -> Double {
        let operation = node.op
        let expr = node.children[1]
        if operation == "+" {
            return try self._process_node(expr)[0]
        }
        if operation == "-" {
            return try -self._process_node(expr)[0]
        }
        throw  UnrollerException.errorprefix(line: node.line, file: node.file)
    }

    /**
     Process a measurement node.
     */
    private func _process_measure(_ node: NodeMeasure) throws {
        let id0 = try self._process_bit_id(node.children[0])
        let id1 = try self._process_bit_id(node.children[1])
        if id0.count != id1.count {
            throw UnrollerException.errorregsize(line: node.line, file: node.file)
        }
        if let backend = self.backend {
            for i in 0..<id0.count {
                try backend.measure(id0[i], id1[i])
            }
        }
    }

    /**
     Process an if node.
     */
    private func _process_if(_ node: NodeIf) throws {
        if let backend = self.backend {
            let creg = node.children[0].name
            if let cval = Int(node.children[1].value) {
                backend.set_condition(creg, cval)
            }
            _ = try self._process_node(node.children[2])
            backend.drop_condition()
        }
    }

    /**
     Process an external function node n.
     */
    private func _process_external(_ node: NodeExternal) throws -> Double {
        let op = node.children[0].name
        let expr = node.children[1]
        let value = try self._process_node(expr)[0]
        switch op {
        case "sin":
            return sin(value)
        case "cos":
            return cos(value)
        case "tan":
            return tan(value)
        case "exp":
            return exp(value)
        case "ln":
            return log(value)
        case "sqrt":
            return sqrt(value)
        default:
            break
        }
        throw UnrollerException.errorexternal(line: node.line, file: node.file)
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
    private func processNodeList(_ node: Node) throws -> [[RegBit]] {
        if node.type != .N_PRIMARYLIST && node.type != .N_IDLIST {
            throw UnrollerException.errortype(type: node.type.rawValue, line: node.line, file: node.file)
        }
        // We process id_list nodes when they are leaves of barriers
        // primary list should only be called for a barrier.
        var regBits: [[RegBit]] = []
        for child in node.children {
            regBits.append(try self._process_bit_id(child))
        }
        return regBits
    }

    /**
     Carry out the action associated with node n.
     */
    private func _process_node(_ node: Node) throws -> [Double] {
        switch node.type {
        case .N_PROGRAM:
            try self._process_children(node)
        case .N_QREG:
            self.qregs[node.name] = node.index
            try self.backend!.new_qreg(node.name, node.index)
        case .N_CREG:
            self.cregs[node.name] = node.index
            try self.backend!.new_creg(node.name, node.index)
        case .N_ID:
            return [try self._process_local_id(node as! NodeId)]
        case .N_INT:
            // We process int nodes when they are leaves of expressions
            // and cast them to float to avoid, for example, 3/2 = 1.
            return [Double(node.value)!]
        case .N_REAL:
            return [Double(node.value)!]
        case .N_INDEXEDID:
            // We should not get here.
            throw UnrollerException.errortypeindexed(line: node.line, file: node.file)
        case .N_GATE:
            try self._process_gate(node as! NodeGate)
        case .N_CUSTOMUNITARY:
            try self._process_custom_unitary(node)
        case .N_UNIVERSALUNITARY:
            let args = try self._process_node(node.children[0])
            let qid = try self._process_bit_id(node.children[1])
            for element in qid {
                try self.backend!.u((args[0], args[1], args[2]), element)
            }
        case .N_CNOT:
            try self._process_cnot(node as! NodeCnot)
        case .N_EXPRESSIONLIST:
            var values: [Double] = []
            for child in node.children {
                values.append(contentsOf: try self._process_node(child))
            }
            return values
        case .N_BINARYOP:
            return [try self._process_binop(node as! NodeBinaryOp)]
        case .N_PREFIX:
            return [try self._process_prefix(node as! NodePrefix)]
        case .N_MEASURE:
            try self._process_measure(node as! NodeMeasure)
        case .N_MAGIC:
            self.version = Double(node.children[0].value)!
            self.backend!.version(node.children[0].value)
        case .N_BARRIER:
            let ids = try self.processNodeList(node.children[0])
            try self.backend!.barrier(ids)
        case .N_RESET:
            let id0 = try self._process_bit_id(node.children[0])
            for idx in 0..<id0.count {
                try self.backend!.reset(id0[idx])
            }
        case .N_IF:
            try self._process_if(node as! NodeIf)
        case .N_OPAQUE:
            try self._process_gate(node as! NodeGate, opaque: true)
        case .N_EXTERNAL:
            return [try self._process_external(node as! NodeExternal)]
        default:
            throw UnrollerException.errortype(type: node.type.rawValue, line: node.line, file: node.file)
        }
        return []
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
