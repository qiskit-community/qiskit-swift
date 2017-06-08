//
//  HashableTuple.swift
//  qiskit
//
//  Created by Manoel Marques on 5/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public typealias TupleInt = HashableTuple<Int,Int>

public struct HashableTuple<A:Hashable,B:Hashable> : Hashable, Equatable {
    public let one: A
    public let two: B

    public init(_ one: A, _ two: B) {
        self.one = one
        self.two = two
    }
    public var hashValue : Int {
        get {
            return self.one.hashValue &* 31 &+ self.two.hashValue
        }
    }

    public static func ==<A:Hashable,B:Hashable>(lhs: HashableTuple<A,B>, rhs: HashableTuple<A,B>) -> Bool {
        return lhs.one == rhs.one && lhs.two == rhs.two
    }
}
