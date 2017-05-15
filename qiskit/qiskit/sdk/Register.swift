//
//  Register.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Quantum or Classical Bit class
 */
public final class Qbit: QId, Decl {

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

public class Register: QId {

    public let name:String
    public let size:Int

    /**
     Create a new generic register.
     */
    public init(_ name: String, _ size: Int) throws {
        var matches: Int = 0
        do {
            let regex = try NSRegularExpression(pattern: "[a-z][a-zA-Z0-9_]*")
            let nsString = name as NSString
            matches = regex.numberOfMatches(in: name, options: [], range: NSRange(location: 0, length: nsString.length))
        } catch let error {
            throw QISKitException.internalError(error: error)
        }
        if matches <= 0 {
            throw QISKitException.regname
        }
        if size <= 0 {
            throw QISKitException.regsize
        }
        self.name = name
        self.size = size
        super.init(name)
    }
}
