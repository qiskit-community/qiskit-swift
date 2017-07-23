//
//  NumUtilities.swift
//  qiskit
//
//  Created by Manoel Marques on 7/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class NumUtilities {

    private init() {
    }

    static func identityComplex(_ n: Int) -> [[Complex]] {
        return (0...n).map {
            let row = $0
            return (0...n).map {
                return row == $0 ? Complex(real: 1.0) : Complex()
            }
        }
    }

    static func zeroComplex(_ rows: Int,_ cols: Int) -> [[Complex]] {
        return (0...rows).map {_ in
            return (0...cols).map {_ in 
                return Complex()
            }
        }
    }

    static func kronComplex(_ a: [[Complex]], _ b: [[Complex]]) -> [[Complex]] {
        let m = a.count
        let n = a.isEmpty ? 0 : a[0].count
        let p = b.count
        let q = b.isEmpty ? 0 : b[0].count

        var ab = NumUtilities.zeroComplex(m * p, n * q)
        for i in 0..<m {
            for j in 0..<n {
                let da = a[i][j]
                for k in 0..<p {
                    for l in 0..<q {
                        let db = b[k][l]
                        ab[p*i + k][q*j + l] = da * db
                    }
                }
            }
        }
        return ab
    }

    static func dotComplex(_ a: [[Complex]], _ b: [[Complex]]) -> [[Complex]] {
        let m = a.count
        let n = a.isEmpty ? 0 : a[0].count
        let q = b.isEmpty ? 0 : b[0].count

        var ab = NumUtilities.zeroComplex(m,q)
        for i in 0..<m {
            for j in 0..<q {
                for k in 0..<n {
                    ab[i][j] += a[i][k] * b[k][j]
                }
            }
        }
        return ab
    }
}
