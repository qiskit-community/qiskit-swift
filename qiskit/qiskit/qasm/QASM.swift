//
//  QASM.swift
//  qiskit
//
//  Created by Manoel Marques on 4/7/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

public protocol QProgram: CustomStringConvertible {
}

public protocol QStatement: QProgram {
}

public protocol QDecl: QStatement {
}

public protocol Qqop: QStatement {
}

public protocol Quop: Qqop {
}

public class QId {

    public var identifier: String { return self.ident }
    private let ident: String

    public init(_ identifier: String) {
        self.ident = identifier
    }
}

/**
 QASM Main class
 */
public final class QASM: CustomStringConvertible {

    public enum QASMFormat {
        case qasmOpen, qasmIBM
    }

    public let format: QASMFormat
    public let majorVersion: Int
    public let minorVersion: Int
    public var programs: [QProgram] = []

    public init(_ format: QASMFormat = QASMFormat.qasmIBM, _ majorVersion: Int = 2, _ minorVersion: Int = 0) {
        self.format = format
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
    }

    public var description: String {
        let name = self.format == QASMFormat.qasmIBM ? "IBMQASM" : "OPENQASM"
        var text = "\(name) \(self.majorVersion).\(self.minorVersion);"
        for program in self.programs {
            text.append("\n\(program.description)")
            if program is QComment || program is QGateDecl {
                continue
            }
            text.append(";")
        }
        return text
    }

    public func append(_ program: QProgram) -> QASM {
        self.programs.append(program)
        return self
    }

    public func append(contentsOf: [QProgram]) -> QASM {
        self.programs.append(contentsOf: contentsOf)
        return self
    }

    public static func + (left: QASM, right: QProgram) -> QASM {
        let qasm = QASM(left.format, left.majorVersion, left.minorVersion)
        return qasm.append(contentsOf: left.programs).append(right)
    }

    public static func += (left: inout QASM, right: QProgram) {
        left.programs.append(right)
    }
}
