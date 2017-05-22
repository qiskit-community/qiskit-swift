//
//  rippleadder.swift
//  QiskitSwift
//
//  Created by Manoel Marques & Joe Ligman on 5/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

final class RippleAdder {

    private class func majority(_ p: QuantumCircuit,
                  _ a: QuantumRegisterTuple,
                  _ b:QuantumRegisterTuple,
                  _ c:QuantumRegisterTuple) {
        _ = try p.cx(c, b)
        _ = try p.cx(c, a)
        _ = try p.ccx(a, b, c)
    }

    private class func unmajority(_ p: QuantumCircuit,
                    _ a: QuantumRegisterTuple,
                    _ b:QuantumRegisterTuple,
                    _ c:QuantumRegisterTuple) throws {
        _ = try p.ccx(a, b, c)
        _ = try p.cx(c, a)
        _ = try p.cx(a, b)
    }

    public func rippleAddition() throws -> QuantumCircuit {

        let cin = try QuantumRegister("cin", 1)
        let a = try QuantumRegister("a", 4)
        let b = try QuantumRegister("b", 4)
        let cout = try QuantumRegister("cout", 1)
        let ans = try ClassicalRegister("ans", 5)
        let circuit = try QuantumCircuit([cin,a,b,cout,ans])
        _ = try circuit.x(a[0])
        _ = try circuit.x(b)
        try RippleAdder.majority(circuit, cin[0], b[0], a[0])
        for j in 0..<3 {
            try RippleAdder.majority(circuit, a[j], b[j + 1], a[j + 1])
        }
        _ = try circuit.cx(a[3], cout[0])
        for j in (0..<3).reversed() {
            try RippleAdder.unmajority(circuit, a[j], b[j + 1], a[j + 1])
        }
        try RippleAdder.unmajority(circuit, cin[0], b[0], a[0])
        for j in 0..<4 {
            _ = try circuit.measure(b[j], ans[j])  // Measure the output register
        }
        _ = try circuit.measure(cout[0], ans[4])

        return circuit

    }

}

