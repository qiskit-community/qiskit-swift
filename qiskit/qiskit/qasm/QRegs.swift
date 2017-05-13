//
//  QRegs.swift
//  qiskit
//
//  Created by Manoel Marques on 4/12/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum or Classical Bit class
 */
public final class Qbit: QId, QDecl {

    public override var identifier: String { return "\(super.identifier)[\(self.index)]" }
    public let index: Int

    init(_ identifier: String, _ index: Int) {
        self.index = index
        super.init(identifier)
    }

    public var description: String {
        return "\(self.identifier)[\(self.index)]"
    }
}

/**
 Qubits Register class
 */
public final class Qqreg: QId, QDecl {

    public let size: Int

    public subscript(index: Int) -> Qbit {
        get {
            if index < 0 || index >= size {
                fatalError("Index out of range")
            }
            return Qbit(self.identifier, index)
        }
    }

    public init(_ identifier: String, _ size: Int) {
        self.size = size
        super.init(identifier)
    }

    public var description: String {
        return "qreg \(self.identifier)[\(self.size)]"
    }
}

/**
 Bits Register class
 */
public final class Qcreg: QId, QDecl {

    public let size: Int

    public subscript(index: Int) -> Qbit {
        get {
            if index < 0 || index >= size {
                fatalError("Index out of range")
            }
            return Qbit(self.identifier, index)
        }
    }

    public init(_ identifier: String, _ size: Int) {
        self.size = size
        super.init(identifier)
    }

    public var description: String {
        return "creg \(self.identifier)[\(self.size)]"
    }
}
