// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation

/**
 Backend for the unroller that produces a QuantumCircuit.

 By default, basis gates are the QX gates.
*/
final class CircuitBackend: UnrollerBackend {

    private var creg:String? = nil
    private var cval:Int? = nil
    private var basis: [String]
    private var gates: [String:GateData] = [:]
    private var listen: Bool = true
    private var in_gate: String = ""
    private let circuit = QuantumCircuit()

    /**
     Setup this backend.
     basis is a list of operation name strings.
     */
    init(_ basis: [String] = ["cx", "u1", "u2", "u3"]) {
        self.basis = basis
    }

    /**
     Declare the set of user-defined gates to emit.
     basis is a list of operation name strings.
     */
    func set_basis(_ basis: [String]) {
        self.basis = basis
    }

    /**
     Print the version string.
     v is a version number.
     */
    func version(_ version: String) {
    }

    /**
     Create a new quantum register.
     name = name of the register
     sz = size of the register
     */
    func new_qreg(_ name: String, _ size: Int) throws {
        try self.circuit.add(QuantumRegister(name, size))
    }

    /**
     Create a new classical register.
     name = name of the register
     sz = size of the register
     */
    func new_creg(_ name: String, _ size: Int) throws {
        try self.circuit.add(ClassicalRegister(name, size))
    }

    /**
     Define a new quantum gate.
     name is a string.
     gatedata is the AST node for the gate.
     */
    func define_gate(_ name: String, _ gatedata: GateData) throws {
        self.gates[name] = gatedata
    }

    /**
     Map qubit tuple (regname, index) to (QuantumRegister, index).
     */
    private func _map_qubit(_ qubit: RegBit) throws -> QuantumRegisterTuple {
        let qregs = self.circuit.get_qregs()
        if let qreg = qregs[qubit.name] {
            return QuantumRegisterTuple(qreg, qubit.index)
        }
        throw BackendError.qregNotExist(name: qubit.name)
    }

    /**
     Map bit tuple (regname, index) to (ClassicalRegister, index).
     */
    private func _map_bit(_ bit: RegBit) throws -> ClassicalRegisterTuple {
        let cregs = self.circuit.get_cregs()
        if let creg = cregs[bit.name] {
            return ClassicalRegisterTuple(creg, bit.index)
        }
        throw BackendError.cregNotExist(name: bit.name)
    }

    /**
     Map creg name to ClassicalRegister.
     */
    private func _map_creg(_ creg: String) throws -> ClassicalRegister {
        let cregs = self.circuit.get_cregs()
        if let creg = cregs[creg] {
            return creg
        }
        throw BackendError.cregNotExist(name: creg)
    }

    /**
     Fundamental single qubit gate.

     arg is 3-tuple of Node expression objects.
     qubit is (regname,idx) tuple.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func u(_ arg: (NodeRealValueProtocol, NodeRealValueProtocol, NodeRealValueProtocol), _ qubit: RegBit, _ nested_scope:[[String:NodeRealValueProtocol]]?) throws {
        if self.listen {
            if !self.basis.contains("U") {
                self.basis.append("U")
            }
            let this_gate = try self.circuit.u_base([try arg.0.real(nested_scope),
                                                     try arg.1.real(nested_scope),
                                                     try arg.2.real(nested_scope)],
                                                    try self._map_qubit(qubit))
            if let reg = self.creg,
                let val = self.cval {
                try this_gate.c_if(self._map_creg(reg), val)
            }
        }
    }

    /**
     Fundamental two qubit gate.
     qubit0 is (regname,idx) tuple for the control qubit.
     qubit1 is (regname,idx) tuple for the target qubit.
     */
    func cx(_ qubit0: RegBit, _ qubit1: RegBit) throws {
        if self.listen {
            if !self.basis.contains("CX") {
                self.basis.append("CX")
            }
            let this_gate = try self.circuit.cx_base(self._map_qubit(qubit0),self._map_qubit(qubit1))
            if let reg = self.creg,
                let val = self.cval {
                try this_gate.c_if(self._map_creg(reg), val)
            }
        }
    }

    /**
     Measurement operation.
     qubit is (regname, idx) tuple for the input qubit.
     bit is (regname, idx) tuple for the output bit.
     */
    func measure(_ qubit: RegBit, _ bit: RegBit) throws {
        if !self.basis.contains("measure") {
            self.basis.append("measure")
        }
        let this_op = try self.circuit.measure(self._map_qubit(qubit),self._map_bit(bit))
        if let reg = self.creg,
            let val = self.cval {
            try this_op.c_if(self._map_creg(reg), val)
        }
    }

    /**
     Barrier instruction.
     qubitlists is a list of lists of (regname, idx) tuples.
     */
    func barrier(_ qubitlists: [[RegBit]]) throws {
        if self.listen {
            if !self.basis.contains("barrier") {
                self.basis.append("barrier")
            }
            var tuples: [QuantumRegisterTuple] = []
            for qubitlists in qubitlists {
                for regBit in qubitlists {
                    tuples.append(try self._map_qubit(regBit))
                }
            }
            try self.circuit.barrier(tuples)
        }
    }

    /**
     Reset instruction.
     qubit is a (regname, idx) tuple.
     */
    func reset(_ qubit: RegBit) throws {
        if !self.basis.contains("reset") {
            self.basis.append("reset")
        }
        let this_op = try self.circuit.reset(self._map_qubit(qubit))
        if let reg = self.creg,
            let val = self.cval {
            try this_op.c_if(self._map_creg(reg), val)
        }
    }

    /**
     Attach a current condition.
     creg is a name string.
     cval is the integer value for the test.
     */
    func set_condition(_ creg: String, _ cval: Int) {
        self.creg = creg
        self.cval = cval
    }

    /**
     Drop the current condition.
     */
    func drop_condition() {
        self.creg = nil
        self.cval = nil
    }

    /**
     Begin a custom gate.

     name is name string.
     args is list of Node expression objects.
     qubits is list of (regname, idx) tuples.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth.
     */
    func start_gate(_ name: String, _ args: [NodeRealValueProtocol], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValueProtocol]]?) throws {
        if self.listen && !self.basis.contains(name) {
            if let gate = self.gates[name] {
                if gate.opaque {
                    throw BackendError.errorOpaque(name: name)
                }
            }
        }
        if self.listen && self.basis.contains(name) {
            self.in_gate = name
            self.listen = false

            var this_gate: Gate? = nil
            if name == "ccx" {
                if 0 != args.count || 3 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.ccx(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]),self._map_qubit(qubits[2]))
            }
            else if name == "ch" {
                if 0 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.ch(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "crz" {
                if  1 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.crz(args[0].real(nested_scope),self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "cswap" {
                if 0 != args.count || 3 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.cswap(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]),self._map_qubit(qubits[2]))
            }
            else if name == "cu1" {
                if 1 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.cu1(args[0].real(nested_scope),self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "cu3" {
                if 3 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.cu3(args[0].real(nested_scope),args[1].real(nested_scope),args[2].real(nested_scope),
                                                 self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "cx" {
                if 0 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.cx(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "cy" {
                if 0 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.cy(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "cz" {
                if 0 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.cz(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "swap" {
                if 0 != args.count || 2 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.swap(self._map_qubit(qubits[0]),self._map_qubit(qubits[1]))
            }
            else if name == "h" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.h(self._map_qubit(qubits[0]))
            }
            else if name == "id" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.iden(self._map_qubit(qubits[0]))
            }
            else if name == "rx" {
                if 1 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.rx(args[0].real(nested_scope),self._map_qubit(qubits[0]))
            }
            else if name == "ry" {
                if 1 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.ry(args[0].real(nested_scope),self._map_qubit(qubits[0]))
            }
            else if name == "rz" {
                if 1 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.rz(args[0].real(nested_scope),self._map_qubit(qubits[0]))
            }
            else if name == "s" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.s(self._map_qubit(qubits[0]))
            }
            else if name == "sdg" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.sdg(self._map_qubit(qubits[0]))
            }
            else if name == "t" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.t(self._map_qubit(qubits[0]))
            }
            else if name == "tdg" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.tdg(self._map_qubit(qubits[0]))
            }
            else if name == "u1" {
                if 1 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.u1(args[0].real(nested_scope),self._map_qubit(qubits[0]))
            }
            else if name == "u2" {
                if 2 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.u2(args[0].real(nested_scope),args[1].real(nested_scope),self._map_qubit(qubits[0]))
            }
            else if name == "u3" {
                if 3 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.u3(args[0].real(nested_scope),args[1].real(nested_scope),args[2].real(nested_scope),
                                                 self._map_qubit(qubits[0]))
            }
            else if name == "x" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.x(self._map_qubit(qubits[0]))
            }
            else if name == "y" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.y(self._map_qubit(qubits[0]))
            }
            else if name == "z" {
                if 0 != args.count || 1 != qubits.count {
                    throw BackendError.gateIncompatible(name: name,args: args.count, qubits: qubits.count)
                }
                this_gate = try self.circuit.z(self._map_qubit(qubits[0]))
            }
            else {
                throw BackendError.gateNotExist(name: name)
            }
            if let reg = self.creg,
                let val = self.cval {
                try this_gate!.c_if(self._map_creg(reg), val)
            }
        }
    }

    /**
     End a custom gate.

     name is name string.
     args is list of Node expression objects.
     qubits is list of (regname, idx) tuples.
     nested_scope is a list of dictionaries mapping expression variables
     to Node expression objects in order of increasing nesting depth..
     */
    func end_gate(_ name: String, _ args: [NodeRealValueProtocol], _ qubits: [RegBit], _ nested_scope:[[String:NodeRealValueProtocol]]?) throws {
        if name == self.in_gate {
            self.in_gate = ""
            self.listen = true
        }
    }

    /**
     Returns the generated circuit.
     */
    func get_output() throws -> Any? {
        return self.circuit
    }
}
