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
public enum IBMQuantumExperienceError: Error, CustomStringConvertible {

    case invalidURL(url: String)
    case nullResponse(url: String)
    case invalidHTTPResponse(response: URLResponse)
    case httpError(url: String, status: Int, msg: String)
    case nullResponseData(url: String)
    case missingTokenId
    case missingJobId
    case missingExecutionId
    case missingStatus
    case timeout
    case missingDevice(device: String)
    case missingRealDevice(device: String)
    case errorDevice(device: String)
    case internalError(error: Error)

    public var description: String {
        switch self {
        case .invalidURL(let url):
            return url
        case .nullResponse(let url):
            return url
        case .invalidHTTPResponse(let response):
            return response.description
        case .httpError(let url, let status, let msg):
            return "\(url) Http status: \(status); \(msg)"
        case .nullResponseData(let url):
            return url
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
        case .missingDevice(let device):
            return "Device \(device) does not exits in Quantum Experience. Only allow ibmqx2 or simulator"
        case .missingRealDevice(let device):
            return "Device \(device) does not exits in Quantum Experience Real Devices. Only allow ibmqx2"
        case .errorDevice(let device):
            return "Device \(device) does not exits"
        case .internalError(let error):
            return error.localizedDescription
        }
    }
}
