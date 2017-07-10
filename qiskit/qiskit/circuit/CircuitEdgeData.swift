//
//  CircuitEdgeData.swift
//  qiskit
//
//  Created by Manoel Marques on 5/29/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class CircuitEdgeData: NSCopying {
    public var name: RegBit {
        get{
            return _name
        }set(value) {
           _name = value
            if self._name.name == "q" && self._name.index == 0 {
                var i:Int = 0
                i += 1
            }
        }
    }

    private var _name: RegBit

    public init(_ name: RegBit) {
        self._name = name
        if self.name.name == "q" && self.name.index == 0 {
            var i:Int = 0
            i += 1
        }
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return CircuitEdgeData(self.name)
    }
}
