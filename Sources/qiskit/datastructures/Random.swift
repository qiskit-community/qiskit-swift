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
import CRandom

final class Random {

    private var nextNextGaussian: Double? = nil
    private var mt: [UInt] = Array<UInt>(repeating: 0, count: Int(N))
    private var mti: Int32 = N + 1

    init() {
    }
    init(_ seed: Int) {
        self.seed(seed)
    }

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
            let multiplier: Double = (-2 * log(s)/s).squareRoot()
            self.nextNextGaussian = v2 * multiplier
            return v1 * multiplier
        }
    }

    func normal(mean: Double, standardDeviation: Double) -> Double {
        return self.nextGaussian() * standardDeviation + mean
    }

    func seed(_ seed: Int) {
        self.mt = Array<UInt>(repeating: 0, count: Int(N))
        self.mti = N + 1
        var randomState = CRandomState(mt:&self.mt, mti:  self.mti)
        var initKey: [UInt] = [UInt(seed)]
        init_by_array(&randomState,&initKey, Int32(initKey.count));
        self.mti = randomState.mti
    }

    /**
    Return the next random floating point number in the range [0.0, 1.0).
    */
    func random() -> Double {
        var randomState = CRandomState(mt:&self.mt, mti: self.mti)
        let result = genrand_res53(&randomState)
        self.mti = randomState.mti
        return result
    }

    func getrandbits(_ bits: UInt) -> UInt32 {
        var k = bits
        var randomState = CRandomState(mt:&self.mt, mti:  self.mti)
        var r: UInt32 = UInt32(genrand_int32(&randomState))
        self.mti = randomState.mti
        if k < 32 {
            return r >> (32 - k)
        }
        let words = Int((k - 1) / 32 + 1)
        var wordarray: [UInt8] = []
        for _ in 0..<words {
            randomState = CRandomState(mt:&self.mt, mti:  self.mti)
            r = UInt32(genrand_int32(&randomState))
            self.mti = randomState.mti
            if k < 32 {
                r >>= (32 - k)  /* Drop least significant bits */
            }
            wordarray.append(contentsOf: Random.toBytes(r))
            k -= 32
        }
        let data = Data(bytes: wordarray)
        return UInt32(bigEndian: data.withUnsafeBytes { $0.pointee })
    }

    /**
     Return a random integer N such that a <= N <= b
     */
    func randint(_ start: UInt32, _ stop: UInt32) -> UInt32 {
        return start + self.randbelow(stop - start + 1)
    }

    /**
     Return a random int in the range [0,n).
     */
    private func randbelow(_ n: UInt32) -> UInt32 {
        let k = UInt(String(n, radix:2).count)
        var r = self.getrandbits(k)
        while r >= n {
            r = getrandbits(k)
        }
        return r
    }

    private static func toBytes(_ number: UInt32) -> [UInt8] {
        let capacity = MemoryLayout<UInt32>.size
        var mutableValue = number
        return withUnsafePointer(to: &mutableValue) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: capacity) {
                return Array(UnsafeBufferPointer(start: $0, count: capacity))
            }
        }
    }
}
