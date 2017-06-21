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

public protocol Register: RegisterArgument, CustomStringConvertible {

    var name:String { get }
    var size:Int { get }
}

extension Register {

    public var identifier: String {
        return self.name
    }

    /**
     Check that i is a valid index.
     */
    public func check_range(_ i: Int) throws {
        if i < 0 || i >= self.size {
            throw QISKitException.regindexrange
        }
    }

    func checkProperties() throws {
        var matches: Int = 0
        do {
            let regex = try NSRegularExpression(pattern: "[a-z][a-zA-Z0-9_]*")
            let nsString = self.name as NSString
            matches = regex.numberOfMatches(in: name, options: [], range: NSRange(location: 0, length: nsString.length))
        } catch {
            throw QISKitException.internalError(error: error)
        }
        if matches <= 0 {
            throw QISKitException.regname
        }
        if self.size <= 0 {
            throw QISKitException.regsize
        }
    }
}
