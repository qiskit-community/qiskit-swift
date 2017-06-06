//
//  CircuitBackend.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class CircuitBackend: UnrollerBackend {

    let circuit: Circuit = Circuit()

    init(_ basis: [String] = []) {
        preconditionFailure("CircuitBackend init not implemented")
    }

}
