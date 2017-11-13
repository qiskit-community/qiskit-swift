// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation
//import GameplayKit

final class Random {

    private var nextNextGaussian: Double? = nil
    //private var source: GKMersenneTwisterRandomSource? = nil

    private func nextGaussian() -> Double {
        if let gaussian = self.nextNextGaussian {
            self.nextNextGaussian = nil
            return gaussian
        } else {
            var v1, v2, s: Double
            repeat {
                v1 = 2 * self.random() - 1 // between -1.0 and 1.0
                v2 = 2 * self.random() - 1 // between -1.0 and 1.0
                s = v1 * v1 + v2 * v2
            } while s >= 1 || s == 0
            let multiplier: Double = sqrt(-2 * log(s)/s)
            self.nextNextGaussian = v2 * multiplier
            return v1 * multiplier
        }
    }

    func normal(mean: Double, standardDeviation: Double) -> Double {
        self.seed(self.getrandbits())
        return self.nextGaussian() * standardDeviation + mean
    }

    func getrandbits() -> Int {
        #if os(Linux)
            return Int(random())
        #else
            return Int(arc4random())
        #endif
    }

    func seed(_ s: Int) {
        #if os(Linux)
            srand(s);
        #else
            srand48(s)
        #endif
        //self.source = GKMersenneTwisterRandomSource(seed: UInt64(s))
    }

    /**
    Return the next random floating point number in the range [0.0, 1.0).
    */
    func random() -> Double {
        //return Double(self.source?.nextUniform() ?? 0.0)
        #if os(Linux)
            return rand()
        #else
            return drand48()
        #endif
    }
}
