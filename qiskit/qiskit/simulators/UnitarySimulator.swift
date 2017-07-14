//
//  UnitarySimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class UnitarySimulator: Simulator {

    private var _result: [String:Any] = [:]

    var result: [String:Any] {
        return self._result
    }
    
    init(_ compiled_circuit: String) {

    }

    func run() throws -> [String:Any] {
        return self._result
    }
}
