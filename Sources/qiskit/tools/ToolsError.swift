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
 Tools Exceptions
 */
public enum ToolsError: LocalizedError, CustomStringConvertible {

    case invalidPauliMultiplication
    case pauliToMatrixZ
    case pauliToMatrixX

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .invalidPauliMultiplication:
            return "Paulis cannot be multiplied - different number of qubits"
        case .pauliToMatrixZ:
            return "The z string is not of the form 0 and 1"
        case .pauliToMatrixX:
            return "The x string is not of the form 0 and 1"
        }
    }
}
