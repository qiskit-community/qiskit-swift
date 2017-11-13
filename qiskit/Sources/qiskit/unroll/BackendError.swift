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
 Exception for errors raised by unroller backends.
 */
public enum BackendError: LocalizedError, CustomStringConvertible {
    case errorOpaque(name: String)
    case qregNotExist(name: String)
    case cregNotExist(name: String)
    case gateNotExist(name: String)
    case gateIncompatible(name: String,args: Int, qubits: Int)

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .errorOpaque(let name):
            return "opaque gate \(name) not in basis"
        case .qregNotExist(let name):
            return "qreg \(name) does not exist"
        case .cregNotExist(let name):
            return "creg \(name) does not exist"
        case .gateNotExist(let name):
            return "gate \(name) not in standard extensions"
        case .gateIncompatible(let name,let args, let qubits):
            return "gate \(name) signature [\(args),\(qubits)] is incompatible with the standard extensions"
        }
    }
}
