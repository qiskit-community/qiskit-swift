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
    var name: RegBit

    init(name: RegBit, type: String) {
        if type(of: self) == CircuitVertexInOutData.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = name
        super.init(type: type)
    }
}

final class CircuitVertexInData: CircuitVertexInOutData {

    init(_ name: RegBit) {
        super.init(name: name, type: "in")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        return CircuitVertexInData(self.name)
    }
}

final class CircuitVertexOutData: CircuitVertexInOutData {

    init(_ name: RegBit) {
        super.init(name: name, type: "out")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        return CircuitVertexOutData(self.name)
    }
}

final class CircuitVertexOpData: CircuitVertexData {
    let name: String
    var qargs: [RegBit]
    var cargs: [RegBit]
    let params: [String]
    var condition: RegBit?

    init(_ name: String,_ qargs: [RegBit], _ cargs: [RegBit], _ params: [String], _ condition: RegBit?) {
        self.name = name
        self.qargs = qargs
        self.cargs = cargs
        self.params = params
        self.condition = condition
        super.init(type: "op")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        return CircuitVertexOpData(self.name,self.qargs,self.cargs,self.params,self.condition)
    }
}

