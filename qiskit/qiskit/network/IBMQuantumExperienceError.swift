//
//  IBMQuantumExperienceError.swift
//  qiskit
//
//  Created by Manoel Marques on 5/16/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Quantum Experience Exceptions
 */
public enum IBMQuantumExperienceError: LocalizedError, CustomStringConvertible {

    case invalidURL(url: String)
    case nullResponse(url: String)
    case invalidHTTPResponse(response: URLResponse)
    case httpError(status: Int, msg: String)
    case nullResponseData(url: String)
    case invalidResponseData
    case missingTokenId
    case missingJobId
    case missingExecutionId
    case missingStatus
    case timeout
    case missingBackend(backend: String)
    case errorBackend(backend: String)
    case errorSeed(backend: String)
    case errorSeedLength
    case missingBackends
    case badBackendError(backend: String)
    case retriesPositive
    case internalError(error: Error)

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .invalidURL(let url):
            return url
        case .nullResponse(let url):
            return url
        case .invalidHTTPResponse(let response):
            return response.description
        case .httpError(let status, let msg):
            return "Http status: \(status); \(msg)"
        case .nullResponseData(let url):
            return url
        case .invalidResponseData:
            return "Invalid response data"
        case .missingTokenId():
            return "Missing TokenId"
        case .missingJobId():
            return "Missing JobId"
        case .missingExecutionId():
            return "Missing ExecutionId"
        case .missingStatus():
            return "Missing Status"
        case .timeout():
            return "Timeout"
        case .missingBackend(let backend):
            return "Backend \(backend) does not exits in Quantum Experience."
        case .errorBackend(let backend):
            return "Backend \(backend) does not exits"
        case .errorSeed(let backend):
            return "No seed allowed in \(backend)"
        case .errorSeedLength():
            return "No seed allowed. Max 10 digits."
        case .missingBackends():
            return "Missing backends"
        case .badBackendError(let backend):
            return "Could not find backend '\(backend)' available."
        case .retriesPositive():
            return "post retries must be positive integer"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
