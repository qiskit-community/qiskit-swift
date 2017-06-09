//
//  Random.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 From java.util.Random nextGaussian
 */
final class Random {

    private var nextNextGaussian: Double? = {
        srand48(Int(arc4random())) // intialize drand48 buffer once
        return nil
    }()

    private func nextDouble() -> Double {
        return drand48()
    }

    private func nextGaussian() -> Double {
        if let gaussian = nextNextGaussian {
            self.nextNextGaussian = nil
            return gaussian
        } else {
            var v1, v2, s: Double
            repeat {
                v1 = 2 * nextDouble() - 1 // between -1.0 and 1.0
                v2 = 2 * nextDouble() - 1 // between -1.0 and 1.0
                s = v1 * v1 + v2 * v2
            } while s >= 1 || s == 0
            let multiplier: Double = sqrt(-2 * log(s)/s)
            self.nextNextGaussian = v2 * multiplier
            return v1 * multiplier
        }
    }

    func normal(mean: Double, standardDeviation: Double) -> Double {
        return self.nextGaussian() * standardDeviation + mean
    }
}
