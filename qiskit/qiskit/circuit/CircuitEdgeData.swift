//
//  CircuitEdgeData.swift
//  qiskit
//
//  Created by Manoel Marques on 5/29/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class CircuitEdgeData: NSCopying {
    public var name: RegBit

    public init(_ name: RegBit) {
        self.name = name
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return CircuitEdgeData(self.name)
    }
}
