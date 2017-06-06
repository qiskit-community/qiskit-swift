//
//  CouplingVertexData.swift
//  qiskit
//
//  Created by Manoel Marques on 6/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class CouplingVertexData: NSCopying {
    let name: RegBit

    init(_ name: RegBit) {
        self.name = name
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        return CouplingVertexData(self.name)
    }
}
