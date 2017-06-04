//
//  Register.swift
//  qiskit
//
//  Created by Manoel Marques on 5/15/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public protocol RegisterArgument {
    var identifier: String { get }
}

public class RegisterTuple: RegisterArgument {
    public var  register: Register {
        return self._register
    }
    public let index: Int
    private let _register: Register

    public var identifier: String {
        return "\(self.register.name)[\(self.index)]"
    }

    init(_ register: Register, _ index: Int) {
        self._register = register
        self.index = index
    }
}

public class Register: RegisterArgument, CustomStringConvertible {

    public let name:String
    public let size:Int

    public var identifier: String {
        return self.name
    }

    public var description: String {
        preconditionFailure("description not implemented")
    }

    /**
     Create a new generic register.
     */
    public init(_ name: String, _ size: Int) throws {
        if type(of: self) == Register.self {
            fatalError("Abstract class instantiation.")
        }
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
    }

    /**
     Check that i is a valid index.
     */
    public func check_range(_ i: Int) throws {
        if i < 0 || i >= self.size {
            throw QISKitException.regindexrange
        }
    }
}
