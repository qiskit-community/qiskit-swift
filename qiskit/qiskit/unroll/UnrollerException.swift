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
public enum UnrollerException: LocalizedError, CustomStringConvertible {
    case errorregname(qasm: String)
    case errorlocalbit(qasm: String)
    case errorlocalparameter(qasm: String)
    case errorundefinedgate(qasm: String)
    case errorqregsize(qasm: String)
    case errorbinop(qasm: String)
    case errorprefix(qasm: String)
    case errorregsize(qasm: String)
    case errorexternal(qasm: String)
    case errortypeindexed(qasm: String)
    case errortype(type: String, qasm: String)
    case errorbackend
    case invalidcircuit
    case invalidJSON

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .errorregname(let qasm):
            return "expected qreg or creg name: qasm='\(qasm)"
        case .errorlocalbit(let qasm):
            return "excepted local bit name: qasm='\(qasm)'"
        case .errorlocalparameter(let qasm):
            return "expected local parameter name: qasm='\(qasm)'"
        case .errorundefinedgate(let qasm):
            return "internal error undefined gate: qasm='\(qasm)'"
        case .errorqregsize(let qasm):
            return "internal error: qreg size mismatch: qasm='\(qasm)'"
        case .errorbinop(let qasm):
            return "internal error: undefined binop: qasm='\(qasm)'"
        case .errorprefix(let qasm):
            return "internal error: undefined prefix: qasm='\(qasm)'"
        case .errorregsize(let qasm):
            return "internal error: reg size mismatch: qasm='\(qasm)'"
        case .errorexternal(let qasm):
            return "internal error: undefined external: qasm='\(qasm)'"
        case .errortypeindexed(let qasm):
            return "internal error n.type == indexed_id: qasm='\(qasm)'"
        case .errortype(let type,let qasm):
            return "internal error: undefined node type \(type): qasm='\(qasm)'"
        case .errorbackend():
            return "backend not attached"
        case .invalidcircuit:
            return "Invalid circuit! Has the Qasm parsing been called?. e.g: unroller.execute()"
        case .invalidJSON():
            return "Invalid JSON Object in backend"
        }
    }
}
