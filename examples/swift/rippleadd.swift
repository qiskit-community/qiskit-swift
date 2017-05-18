//
//  rippleadder.swift
//  QiskitSwift
//
//  Created by Manoel Marques & Joe Ligman on 5/18/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskit

class RippleAdder {
    
    private func majority(_ p: inout QuantumCircuit,
                  _ a: QuantumRegisterTuple,
                  _ b:QuantumRegisterTuple,
                  _ c:QuantumRegisterTuple) {
        p += CnotGate(c, b)
        p += CnotGate(c, a)
        p += ToffoliGate(a, b, c)
    }

    private func unmajority(_ p: inout QuantumCircuit,
                    _ a: QuantumRegisterTuple,
                    _ b:QuantumRegisterTuple,
                    _ c:QuantumRegisterTuple) throws {
        p += ToffoliGate(a, b, c)
        p += CnotGate(c, a)
        p += CnotGate(a, b)
    }

    public func rippleAddition() throws -> QuantumCircuit {

        let cin = try QuantumRegister("cin", 1)
        let a = try QuantumRegister("a", 4)
        let b = try QuantumRegister("b", 4)
        let cout = try QuantumRegister("cout", 1)
        let ans = try ClassicalRegister("ans", 5)
        
        var circuit = try QuantumCircuit([cin,a,b,cout,ans])
        circuit += XGate(a[0])
        circuit += XGate(b)
        majority(&circuit, cin[0], b[0], a[0])
        for j in 0..<3 {
            majority(&circuit, a[j], b[j + 1], a[j + 1])
        }
        circuit += CnotGate(a[3], cout[0])
        for j in (0..<3).reversed() {
            try unmajority(&circuit, a[j], b[j + 1], a[j + 1])
        }
        try unmajority(&circuit, cin[0], b[0], a[0])
        for j in 0..<4 {
            circuit += Measure(b[j], ans[j])
        }
        circuit += Measure(cout[0], ans[4])
        
        return circuit

    }

}

