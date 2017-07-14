//
//  QasmCppSimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class QasmCppSimulator: Simulator {

    private var _result: [String:Any] = [:]

    var result: [String:Any] {
        return self._result
    }

    init(_ compiled_circuit: String, _ shots: Int = 1024, _ seed: Double?) {

    }
    
    func run() throws -> [String:Any] {
        return self._result
    }
}
