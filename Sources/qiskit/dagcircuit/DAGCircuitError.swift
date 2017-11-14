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
 Exception for errors raised by the Circuit object.
 */
public enum DAGCircuitError: LocalizedError, CustomStringConvertible {
    case duplicateRegister(name: String)
    case noRegister(name: String)
    case duplicateWire(regBit: RegBit)
    case noBasicOp(name: String)
    case gateMatch
    case qbitsNumber(name: String)
    case bitsNumber(name: String)
    case paramsNumber(name: String)
    case cregCondition(name: String)
    case bitNotFound(q: RegBit)
    case wireType(bVal: Bool, q: RegBit)
    case incompatibleBasis
    case ineqGate(name: String)
    case wireFrag(name: String)
    case unmappeDupName(name: String)
    case invalidWireMapKey(regBit: RegBit)
    case invalidWireMapValue(regBit: RegBit)
    case inconsistenteWireMap(name: RegBit, value: RegBit)
    case duplicatesWireMap
    case duplicateWires
    case totalWires(expected: Int, total: Int)
    case missingWire(wire: RegBit)
    case missingName(name: String)
    case invalidOpType(type: String)

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .duplicateRegister(let name):
            return "duplicate register name '\(name)'"
        case .noRegister(let name):
            return "no register name '\(name)'"
        case .duplicateWire(let regBit):
            return "duplicate wire '\(regBit.name)-\(regBit.index)'"
        case .noBasicOp(let name):
            return "\(name) is not in the list of basis operations"
        case .gateMatch:
            return "gate data does not match basis element specification"
        case .qbitsNumber(let name):
            return "incorrect number of qubits for \(name)"
        case .bitsNumber(let name):
            return "incorrect number of bits for \(name)"
        case .paramsNumber(let name):
            return "incorrect number of parameters for \(name)"
        case .cregCondition(let name):
            return "invalid creg in condition for \(name)"
        case .bitNotFound(let q):
            return "(qu)bit \(q.qasm) not found"
        case .wireType(let bVal, let q):
            return "expected wire type \(bVal) for \(q.qasm)"
        case .incompatibleBasis:
            return "incompatible basis"
        case .ineqGate(let name):
            return "inequivalent gate definitions for \(name)"
        case .wireFrag(let name):
            return "wire_map fragments reg \(name)"
        case .unmappeDupName(let name):
            return "unmapped duplicate reg \(name)"
        case .invalidWireMapKey(let regBit):
            return "invalid wire mapping key \(regBit.qasm)"
        case .invalidWireMapValue(let regBit):
            return "invalid wire mapping value \(regBit.qasm)"
        case .inconsistenteWireMap(let name, let value):
            return "inconsistent wire_map at (\(name.qasm),\(value.qasm))"
        case .duplicatesWireMap:
            return "duplicates in wire_map"
        case .duplicateWires:
            return "duplicate wires"
        case .totalWires(let expected, let total):
            return "expected \(expected) wires, got \(total)"
        case .missingWire(let w):
            return "wire (\(w.name),\(w.index)) not in input circuit"
        case .missingName(let name):
            return "\(name) is not in the list of basis operations"
        case .invalidOpType(let type):
            return "expected node type \"op\", got \(type)"
        }
    }
}
