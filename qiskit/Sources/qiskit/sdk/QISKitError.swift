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
 QISKit SDK Errors
 */
public enum QISKitError: LocalizedError, CustomStringConvertible {

    case intructionCircuitNil
    case regExists(name: String)
    case regNotExists(name: String)
    case controlValueNegative
    case notCreg
    case regNotInCircuit(name: String)
    case regName
    case regSize
    case controlRegNotFound(name: String)
    case not3Params
    case notQubitGate(qubit: QuantumRegisterTuple)
    case duplicateQubits
    case regIndexRange
    case circuitsNotCompatible
    case noArguments
    case missingFileName
    case missingCircuit
    case missingCircuits
    case missingQuantumProgram(name: String)
    case missingCompiledConfig
    case missingCompiledQasm
    case errorShots
    case errorMaxCredit
    case missingStatus
    case timeout
    case errorStatus(status: String)
    case errorResult(result: ResultError)
    case errorLocalSimulator
    case missingJobId
    case parserError(msg: String)
    case missingBackend(backend: String)
    case registerSize
    case noQASM(name: String)
    case noData(name: String)
    case noCounts(name: String)
    case invalidResultsCombine
    case internalError(error: Error)

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .intructionCircuitNil:
            return "Instruction's circuit not assigned"
        case .regExists(let name):
            return "register '\(name)'already exists"
        case .regNotExists(let name):
            return "register '\(name)'does not exist"
        case .controlValueNegative:
            return "control value should be non-negative"
        case .notCreg:
            return "expected classical register"
        case .regNotInCircuit(let name):
            return "register '\(name)' not in this circuit"
        case .regName:
            return "invalid OPENQASM register name"
        case .regSize:
             return "register size must be positive"
        case .controlRegNotFound(let name):
            return "control register \(name) not found"
        case .not3Params:
            return "Expected 3 parameters."
        case .notQubitGate(let qubit):
            return "qubit '\(qubit.identifier)' not argument of gate."
        case .duplicateQubits:
            return "duplicate qubit arguments"
        case .regIndexRange:
            return "register index out of range"
        case .circuitsNotCompatible:
            return "circuits are not compatible"
        case .noArguments:
            return "no arguments passed"
        case .missingFileName:
            return "No filename provided"
        case .missingCircuit:
            return "Circuit not found"
        case .missingCircuits:
            return "No circuits"
        case .missingQuantumProgram(let name):
            return "result: \(name) not in QuantumProgram"
        case .missingCompiledConfig:
            return "No compiled configuration for this circuit"
        case .missingCompiledQasm:
            return "No compiled qasm for this circuit"
        case .errorShots:
            return "Online backends only support job batches with equal numbers of shots"
        case .errorMaxCredit:
            return "Online backends only support job batches with equal max credit"
        case .missingStatus:
            return "Missing Status"
        case .timeout:
            return "Timeout"
        case .errorStatus(let status):
            return "status: \(status)"
        case .errorResult(let result):
            return result.description
        case .errorLocalSimulator:
            return "Not a local simulator"
        case .missingJobId:
            return "Missing JobId"
        case .parserError(let msg):
            return "QASM Parser error: \(msg)"
        case .missingBackend(let backend):
            return "Unrecognized \(backend)"
        case .registerSize:
            return "Can't make this register: Already in program with different size"
        case .noQASM(let name):
            return "No  qasm for circuit \(name)"
        case .noData(let name):
            return "No data for circuit \(name)"
        case .noCounts(let name):
            return "'No counts for circuit \(name)"
        case .invalidResultsCombine:
            return "Result objects have different configs and cannot be combined."
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
