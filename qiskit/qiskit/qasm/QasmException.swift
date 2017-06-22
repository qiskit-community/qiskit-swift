//
//  QasmException.swift
//  qiskit
//
//  Created by Joe Ligman on 6/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public enum QasmException: LocalizedError, CustomStringConvertible {

    case error(msg: String)
    
    public var errorDescription: String? {
        return self.description
    }
    
    public var description: String {
        switch self {
        case .error(let msg):
            return msg
        }
    }
}
