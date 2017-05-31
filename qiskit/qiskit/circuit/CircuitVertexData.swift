//
//  CircuitVertexData.swift
//  qiskit
//
//  Created by Manoel Marques on 5/29/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class CircuitVertexData: NSCopying {
    let type: String
    var qargs: [HashableTuple<String,Int>] = []
    var cargs: [HashableTuple<String,Int>] = []
    var params: [String] = []
    var condition: HashableTuple<String,Int>? = nil

    init(type: String) {
        if type(of: self) == CircuitVertexData.self {
            fatalError("Abstract class instantiation.")
        }
        self.type = type
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        preconditionFailure("copy not implemented")
    }
}

class CircuitVertexInOutData: CircuitVertexData {
    var name: HashableTuple<String,Int>

    init(name: HashableTuple<String,Int>, type: String) {
        if type(of: self) == CircuitVertexInOutData.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = name
        super.init(type: type)
    }
}

final class CircuitVertexInData: CircuitVertexInOutData {

    init(_ name: HashableTuple<String,Int>) {
        super.init(name: name, type: "in")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = CircuitVertexInData(self.name)
        copy.qargs = self.qargs
        copy.cargs = self.cargs
        copy.params = self.params
        copy.condition = self.condition
        return copy
    }
}

final class CircuitVertexOutData: CircuitVertexInOutData {

    init(_ name: HashableTuple<String,Int>) {
        super.init(name: name, type: "out")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = CircuitVertexOutData(self.name)
        copy.qargs = self.qargs
        copy.cargs = self.cargs
        copy.params = self.params
        copy.condition = self.condition
        return copy
    }
}


final class CircuitVertexOpData: CircuitVertexData {
    let name: String

    init(_ name: String) {
        self.name = name
        super.init(type: "op")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = CircuitVertexOpData(self.name)
        copy.qargs = self.qargs
        copy.cargs = self.cargs
        copy.params = self.params
        copy.condition = self.condition
        return copy
    }
}

