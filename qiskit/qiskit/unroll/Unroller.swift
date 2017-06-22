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
        if let anylist = node.anylist {
            args = try self._process_list(anylist)
        }
        if let explist = node.explist {
            args += try self._process_node(explist)
        }
        
        var bits: [[RegBit]] = []
        if let nodeId = (node.op as? NodeId) {
            if nodeId.is_bit {
                bits.append(try self._process_bit_id(nodeId))
            }
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
        throw UnrollerException.errorundefinedgate(qasm: node.qasm())
    }


    
    /**
     Process a gate decl node.
     If opaque is True, process the node as an opaque gate node.
     """Process a gate node.
    */
    private func _process_gate_decl(_ node: NodeGateDecl, opaque: Bool = false) throws {
        
        guard let gate: NodeGate = node.gate as? NodeGate else { throw UnrollerException.errorlocalparameter(qasm: node.qasm()) }
  
        var args: [String] = []
        
        if let arglist = gate.arguments as? NodeIdList {
            if let ids = arglist.identifiers {
                for i in ids {
                    args.append(i.name)
                }
            }
        }
 
        var bits: [String] = []
        if let bitlist = gate.bitlist as? NodeIdList {
            if let ids = bitlist.identifiers {
                for i in ids {
                    bits.append(i.name)
                }
            }
        }
        
        let body: NodeGateBody? = (opaque) ? nil : (node.gateBody as? NodeGateBody)
        let gatedata = GateData(opaque, args.count, bits.count, args, bits, body)
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
     Process a measurement node.
     */
    private func _process_measure(_ node: NodeQop) throws {
        if node.op?.type == .N_MEASURE {
            guard let argument1 = node.arg as? NodeIdList else { throw UnrollerException.errorlocalparameter(qasm: node.qasm()) }
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
    }

    /**
     Process an if node.
     */
    private func _process_if(_ node: NodeStatment) throws {
//        if node.opeation?.type == .N_IF {
//            if let arg1 = node.p2 as? NodeId,
//                let arg2 = node.p3 as? NodeNNInt,
//                let arg3 = node.p4 as? NodeUniversalUnitary {
//                if let backend = self.backend {
//                    backend.set_condition(arg1.name, arg2.value)
//                    _ = try self._process_node(arg3)
//                    backend.drop_condition()
//                }
//            }
//        }
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
     Process an external function node n.
     */
    private func _process_external(_ node: NodePrefix) throws -> Double {
        guard let ext = node.external else { throw UnrollerException.errorexternal(qasm: node.qasm()) }
        let child = node._children[0]
        var value = Double.leastNormalMagnitude
        if child.type == .N_REAL {
            value = Double((child as! NodeReal).value)
        }
        if child.type == .N_INT {
            value = Double((child as! NodeNNInt).value)
        }

        let op = ext.operation
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
        throw UnrollerException.errorexternal(qasm: node.qasm())
    }
    
    
    private func _process_list(_ node: Node) throws ->[Double] {
        return []
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
//        if node.type != .N_PRIMARYLIST && node.type != .N_IDLIST {
//            throw UnrollerException.errortype(type: node.type.rawValue, qasm: node.qasm())
//        }
//        // We process id_list nodes when they are leaves of barriers
//        // primary list should only be called for a barrier.
//        var regBits: [[RegBit]] = []
//        for child in node.children {
//            regBits.append(try self._process_bit_id(child))
//        }
//        return regBits
        return []
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
            let pnode = (node as! NodeProgram)
            if let programs = pnode.program {
                for p in programs {
                    try self._process_node(p)
                }
            }
            if let statements = pnode.statements {
                for s in statements {
                    try self._process_node(s)
                }
            }
        case .N_QREG:
            let n = node as! NodeQreg
            self.qregs[node.name] = n.index
            try self.backend!.new_qreg(node.name, n.index)
        case .N_CREG:
            let n = node as! NodeCreg
            self.cregs[node.name] = n.index
            try self.backend!.new_creg(node.name, n.index)
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
        case .N_GATEDECL:
            try self._process_gate_decl(node as! NodeGateDecl)
  
        case .N_CUSTOMUNITARY:
            try self._process_custom_unitary(node as! NodeCustomUnitary)
        
        case .N_UNIVERSALUNITARY:
            let unode = node as! NodeUniversalUnitary
            if let c0 = unode.elistorarg,
                let c1 = unode.argument {
                let args = try self._process_node(c0)
                let qid = try self._process_bit_id(c1)
                for element in qid {
                    try self.backend!.u((args[0], args[1], args[2]), element)
                }
            }
        case .N_CNOT:
            try self._process_cnot(node as! NodeCnot)
        case .N_QOP:
            let qopnode = node as! NodeQop
            if qopnode.op?.type == .N_MEASURE {
                try self._process_measure(qopnode)
            } else if qopnode.op?.type == .N_RESET {
                if let arg = qopnode.arg {
                    let id0 = try self._process_bit_id(arg)
                    for idx in 0..<id0.count {
                        try self.backend!.reset(id0[idx])
                    }
                }
            }
        case .N_EXPRESSIONLIST:
            guard let explist = (node as! NodeExpressionList).expressionList else { return [] }
            var values: [Double] = []
            for child in explist {
                values.append(contentsOf: try self._process_node(child))
            }
            return values
        case .N_BINARYOP:
            return [try self._process_binop(node as! NodeBinaryOp)]
        case .N_PREFIX:
            return [try self._process_prefix(node as! NodePrefix)]
        case .N_MAGIC:
            //self.version = Double(node.children[0].value)!
            //self.backend!.version(node.children[0].value)
            break
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
