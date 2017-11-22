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
 Exception for errors raised by the Mapping object.
 */
public enum MappingError: LocalizedError, CustomStringConvertible {
    case layoutError
    case unexpectedSignature(a: Int, b: Int, c: Int)
    case errorCouplingGraph(cxedge: TupleRegBit)
    case errorQubitsCouplingGraph
    case errorQubitInputCircuit(regBit: RegBit)
    case errorQubitInCouplingGraph(regBit: RegBit)
    case swapMapperFailed(i: Int, j: Int, qasm: String)
    case eulerAngles1q2_2
    case eulerAngles1qResult

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .layoutError:
            return "Layer contains >2 qubit gates"
        case .unexpectedSignature(let a, let b, let c):
            return "cx gate has unexpected signature(\(a),\(b),\(c))"
        case .errorCouplingGraph(let cxedge):
            return "circuit incompatible with CouplingGraph: cx on \(cxedge.one.description),\(cxedge.two.description)"
        case .errorQubitsCouplingGraph:
            return "Not enough qubits in CouplingGraph"
        case .errorQubitInputCircuit(let regBit):
            return "initial_layout qubit \(regBit.description) not in input Circuit"
        case .errorQubitInCouplingGraph(let regBit):
            return "initial_layout qubit \(regBit.description) not in input CouplingGraph"
        case .swapMapperFailed(let i, let j, let qasm):
            return "swap_mapper failed: layer \(i), sublayer \(j), \"\(qasm)\""
        case .eulerAngles1q2_2:
            return "compiling.euler_angles_1q expected 2x2 matrix"
        case .eulerAngles1qResult:
            return "compiling.euler_angles_1q incorrect result"
        }
    }
}
