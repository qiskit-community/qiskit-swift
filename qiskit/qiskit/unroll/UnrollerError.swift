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
 Exception for errors raised by unroller.
 */
public enum UnrollerError: LocalizedError, CustomStringConvertible {
    case errorRegName(qasm: String)
    case errorLocalBit(qasm: String)
    case errorUndefinedGate(qasm: String)
    case errorQregSize(qasm: String)
    case errorRegSize(qasm: String)
    case errorTypeIndexed(qasm: String)
    case errorType(type: String, qasm: String)
    case errorBackend
    case invalidCircuit
    case invalidJSON
    case processNodeId
    case processNodeInt
    case processNodeReal
    case processNodeIndexedId
    case processNodeBinop
    case processNodePrefix
    case processNodeExternal

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .errorRegName(let qasm):
            return "expected qreg or creg name: qasm='\(qasm)"
        case .errorLocalBit(let qasm):
            return "excepted local bit name: qasm='\(qasm)'"
        case .errorUndefinedGate(let qasm):
            return "internal error undefined gate: qasm='\(qasm)'"
        case .errorQregSize(let qasm):
            return "internal error: qreg size mismatch: qasm='\(qasm)'"
        case .errorRegSize(let qasm):
            return "internal error: reg size mismatch: qasm='\(qasm)'"
        case .errorTypeIndexed(let qasm):
            return "internal error n.type == indexed_id: qasm='\(qasm)'"
        case .errorType(let type,let qasm):
            return "internal error: undefined node type \(type): qasm='\(qasm)'"
        case .errorBackend():
            return "backend not attached"
        case .invalidCircuit:
            return "Invalid circuit! Has the Qasm parsing been called?. e.g: unroller.execute()"
        case .invalidJSON():
            return "Invalid JSON Object in backend"
        case .processNodeId():
            return "internal error: _process_node on id"
        case .processNodeInt():
           return "internal error: _process_node on int"
        case .processNodeReal():
            return "internal error: _process_node on real"
        case .processNodeIndexedId():
            return "internal error: _process_node on indexed_id"
        case .processNodeBinop():
            return "internal error: _process_node on binop"
        case .processNodePrefix():
            return "internal error: _process_node on prefix"
        case .processNodeExternal():
            return"internal error: _process_node on external"
        }
    }
}
