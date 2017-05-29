//
//  CircuitVertexData.swift
//  qiskit
//
//  Created by Manoel Marques on 5/29/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class CircuitVertexData: NSCopying {
    public var name: HashableTuple<String,Int>
    public let type: String
    public var qargs: [HashableTuple<String,Int>] = []
    public var cargs: [HashableTuple<String,Int>] = []
    public var params: [String] = []
     public var condition: HashableTuple<String,Int>? = nil

    public init(_ name: HashableTuple<String,Int>, _ type: String) {
        self.name = name
        self.type = type
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = CircuitVertexData(self.name, self.type)
        copy.condition = self.condition
        copy.qargs = self.qargs
        copy.cargs = self.cargs
        return copy
    }
}

