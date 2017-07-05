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
    private let ast: NodeMainProgram
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
    init(_ ast: NodeMainProgram, _ backend: UnrollerBackend? = nil) {
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
            let n = node as! NodeIndexedId
            return [RegBit(node.name, n.index)]
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
                throw UnrollerException.errorregname(qasm: node.qasm())
            }
            // local scope
            if let regBit = bits[node.name] {
                return [regBit]
            }
            throw UnrollerException.errorlocalbit(qasm: node.qasm())
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
        throw UnrollerException.errorlocalparameter(qasm: node.qasm())
    }

    /**
     Process a custom unitary node.
     */
    private func _process_custom_unitary(_ node: NodeCustomUnitary) throws {

        let name = node.name
        var args: [Double] = []
        var bits: [[RegBit]] = []
        if let list = node.arguments {
            args = try self._process_node(list)
        }
        var maxidx: Int = 0
        if let blchildren = node.bitlist?.children {
            for node_element in blchildren {
                let bitList = try self._process_bit_id(node_element)
                if maxidx < bitList.count {
                    maxidx = bitList.count
                }
                bits.append(bitList)
            }
        }

        if let gate = self.gates[name] {
            let gargs = gate.args
            let gbits = gate.bits
            let gbody = gate.body
            // Loop over register arguments, if any.
            for idx in 0..<maxidx {
                var map: [String:Double] = [:]
                for (j, garg) in gargs.enumerated() {
                    map[garg] = args[j]
                }
                self.arg_stack.push(map)
                // Only index into register arguments.
                var element: [Int] = []
                for bitList in bits {
                    let condition = bitList.count > 1 ? 1 : 0
                    element.append(idx * condition)
                }
                var regBitMap: [String:RegBit] = [:]
                for (j, gbit) in gbits.enumerated() {
                    regBitMap[gbit] = bits[j][element[j]]
                }
                self.bit_stack.push(regBitMap)
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
        throw UnrollerException.errorundefinedgate(qasm: node.qasm())
    }
    
    /**
     Process a gate decl node.
     If opaque is True, process the node as an opaque gate node.
     """Process a gate node.
    */
    private func _process_gate(_ node: NodeGate) throws {
        
        let n_args = node.n_args
        let n_bits = node.n_bits
        
        var args: [String] = []
        if let arguments = node.arguments as? NodeIdList {
            for a in arguments.children {
                args.append((a as! NodeId).name)
            }
        }
        
        var bits: [String] = []
        if let bitlist = node.bitlist as? NodeIdList{
            for b in bitlist.children {
                bits.append((b as! NodeId).name)
            }
            
        }
        
        let body: NodeGateBody? = node.body as? NodeGateBody
        let gatedata = GateData(false, n_args, n_bits, args, bits, body)
        self.gates[node.name] = gatedata
        if let backend = self.backend {
            try backend.define_gate(node.name, gatedata.copy(with: nil) as! GateData)
        }        
    }

    private func _process_opaque(_ node: NodeOpaque) throws {
        
        let n_args = node.n_args
        let n_bits = node.n_bits
        
        var args: [String] = []
        if let arguments = node.arguments as? NodeIdList {
            for a in arguments.children {
                args.append((a as! NodeId).name)
            }
        }
        
        var bits: [String] = []
        if let bitlist = node.bitlist as? NodeIdList{
            for b in bitlist.children {
                bits.append((b as! NodeId).name)
            }
            
        }

        let gatedata = GateData(false, n_args, n_bits, args, bits, nil)
        self.gates[node.name] = gatedata
        if let backend = self.backend {
            try backend.define_gate(node.name, gatedata.copy(with: nil) as! GateData)
        }
    }
    
    /**
     Process a CNOT gate node.
     */
    private func _process_cnot(_ node: NodeCnot) throws {
        
        guard let argument1 = node.arg1 as? NodeIdList else { throw UnrollerException.errorlocalparameter(qasm: node.qasm()) }
        guard let argument2 = node.arg2 as? NodeIdList else { throw UnrollerException.errorlocalparameter(qasm: node.qasm()) }
        
        let id0 = try self._process_bit_id(argument1)
        let id1 = try self._process_bit_id(argument2)
        
        if !(id0.count == id1.count || id0.count == 1 || id1.count == 1) {
            throw UnrollerException.errorqregsize(qasm: node.qasm())
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
        let lexpr = node._children[1]
        let rexpr = node._children[2]
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
        throw UnrollerException.errorbinop(qasm: node.qasm())
    }
    
    /**
     Process a prefix node.
     */
    private func _process_prefix(_ node: NodePrefix) throws -> Double {
        let operation = node.op
        let expr = node._children[0]
        if operation == "+" {
            return try self._process_node(expr)[0]
        }
        if operation == "-" {
            return try -self._process_node(expr)[0]
        }
        throw  UnrollerException.errorprefix(qasm: node.qasm())
    }
    
    /**
     Process a measurement node.
     */
    private func _process_measure(_ node: NodeMeasure) throws {
        guard let argument1 = node.arg1 as? NodeIdList else { throw UnrollerException.errorlocalparameter(qasm: node.qasm()) }
        guard let argument2 = node.arg2 as? NodeIdList else { throw UnrollerException.errorlocalparameter(qasm: node.qasm()) }
        
        let id0 = try self._process_bit_id(argument1)
        let id1 = try self._process_bit_id(argument2)
        if id0.count != id1.count {
            throw UnrollerException.errorregsize(qasm: node.qasm())
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
        if let creg = node.nodeId as? NodeId,
            let cval = node.nodeNNInt as? NodeNNInt {
            if let backend = self.backend {
                backend.set_condition(creg.name, cval.value)
                _ = try self._process_node(node.children[2])
                backend.drop_condition()
            }
        }
    }
    
    /**
     Process an external function node n.
     */
    private func _process_external(_ node: NodeExternal) throws -> Double {
 
        let op = node.children[0].name
        let expression = node.children[1]
        if let value: Double = try self._process_node(expression).first {
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
        }
        throw UnrollerException.errorexternal(qasm: node.qasm())
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
    @discardableResult
    private func _process_node(_ node: Node) throws -> [Double] {
        switch node.type {
        case .N_MAINPROGRAM:
            if let pnode = (node as! NodeMainProgram).program {
                try self._process_node(pnode)
            }
        case .N_PROGRAM:
            try self._process_children(node)
        case .N_QREG:
            let n = node as! NodeQreg
            self.qregs[n.name] = n.index
            try self.backend!.new_qreg(n.name, n.index)
        case .N_CREG:
            let n = node as! NodeCreg
            self.cregs[n.name] = n.index
            try self.backend!.new_creg(n.name, n.index)
        case .N_ID:
            return [try self._process_local_id(node as! NodeId)]
        case .N_INT:
            // We process int nodes when they are leaves of expressions
            // and cast them to float to avoid, for example, 3/2 = 1.
            let n = node as! NodeNNInt
            return [Double(n.value)]
        case .N_REAL:
            let n = node as! NodeReal
            return [Double(n.value)]
        case .N_INDEXEDID:
            // We should not get here.
            throw UnrollerException.errortypeindexed(qasm: node.qasm())
        case .N_IDLIST:
            var bitids:[Double] = []
            for child in (node as! NodeIdList).children {
                let regbits = try self._process_bit_id(child)
                for rb in regbits {
                    bitids.append(Double(rb.index))
                }
            }
            return bitids
        case .N_PRIMARYLIST:
            var bitids:[Double] = []
            for child in (node as! NodePrimaryList).children {
                let regbits = try self._process_bit_id(child)
                for rb in regbits {
                    bitids.append(Double(rb.index))
                }
            }
            return bitids
        case .N_GATE:
            try self._process_gate(node as! NodeGate)
        case .N_GATEOPLIST:
            try self._process_children(node)
        case .N_CUSTOMUNITARY:
            try self._process_custom_unitary(node as! NodeCustomUnitary)
        case .N_UNIVERSALUNITARY:
            let unode = node as! NodeUniversalUnitary
            if let c0 = unode.explist,
                let c1 = unode.indexedid {
                let args = try self._process_node(c0)
                let qid = try self._process_bit_id(c1)
                for element in qid {
                    try self.backend!.u((args[0], args[1], args[2]), element)
                }
            }
        case .N_CNOT:
            try self._process_cnot(node as! NodeCnot)
        case .N_EXPRESSIONLIST:
            var list:[Double] = []
            for child in node.children {
                let ret = try self._process_node(child)
                list.append(contentsOf: ret)
            }
            return list
        case .N_BINARYOP:
            return [try self._process_binop(node as! NodeBinaryOp)]
        case .N_PREFIX:
            return [try self._process_prefix(node as! NodePrefix)]
        case .N_MEASURE:
            try self._process_measure(node as! NodeMeasure)
        case .N_MAGIC:
            if let magicVersion = (node as! NodeMagic).nodeVersion {
                self.version = Double(magicVersion.value)
                self.backend!.version("\(magicVersion.value)")
            }
        case .N_BARRIER:
            let ids = try self._process_node((node as! NodeBarrier).children[0]) // FIXME ??
            var regbits: [RegBit] = []
            for i in ids {
                regbits.append(RegBit("barrier", Int(i)))
            }
            try self.backend?.barrier([regbits])
        case .N_RESET:
            let id0 = try self._process_bit_id((node as! NodeReset).children[0])
            for idx in 0..<id0.count {
                try self.backend!.reset(id0[idx])
            }
        case .N_IF:
            try self._process_if(node as! NodeIf)
        case .N_OPAQUE:
            try self._process_opaque(node as! NodeOpaque)
        case .N_EXTERNAL:
            return [try self._process_external(node as! NodeExternal)]
        default:
            throw UnrollerException.errortype(type: node.type.rawValue, qasm: node.qasm())
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
            return
        }
        throw UnrollerException.errorbackend
    }
}
