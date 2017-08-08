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
public enum BackendException: LocalizedError, CustomStringConvertible {
    case erroropaque(name: String)
    case qregadded
    case ifnotsupported

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .erroropaque(let name):
            return "opaque gate \(name) not in basis"
        case .qregadded():
            return "sorry, already added the qreg; please declare all qregs before applying a gate"
        case .ifnotsupported():
            return "UnitarySimulator does not support if"
        }
    }
}
