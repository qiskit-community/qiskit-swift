//
//  Unroller.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class Unroller {

    let backend: UnrollerBackend?

    init(_ ast: Node, _ backend: UnrollerBackend? = nil) {
        self.backend = backend
    }

    func execute() {
        preconditionFailure("Unroller execute not implemented")
    }
}
