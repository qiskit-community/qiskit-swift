//
//  RegBit.swift
//  qiskit
//
//  Created by Manoel Marques on 5/31/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public struct RegBit: Hashable, Equatable, CustomStringConvertible {

    private let tuple: HashableTuple<String,Int>

    public var name: String {
        return self.tuple.one
    }
    public var index: Int {
        return self.tuple.two
    }
    public var qasm: String {
        return RegBit.qasm(self.name,self.index)
    }
    public var description: String {
        return self.qasm
    }

    init(_ name: String, _ index: Int) {
        self.tuple = HashableTuple<String,Int>(name,index)
    }

    public static func qasm(_ name: String, _ index: Int) -> String {
        return "\(name)[\(index)]"
    }

    public var hashValue : Int {
        get {
            return self.tuple.hashValue
        }
    }
    public static func ==(lhs: RegBit, rhs:RegBit) -> Bool {
        return lhs.tuple == rhs.tuple
    }
}
