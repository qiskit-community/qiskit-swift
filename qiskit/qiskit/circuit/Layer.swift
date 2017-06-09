//
//  Layer.swift
//  qiskit
//
//  Created by Manoel Marques on 6/1/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class Layer {
    public let graph: Circuit
    public let partition : [[RegBit]]

    init(_ graph: Circuit, _ partition: [[RegBit]]) {
        self.graph = graph
        self.partition = partition
    }
}
