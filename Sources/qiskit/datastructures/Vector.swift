
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

public struct Vector<T: NumericType> : Hashable, Sequence, CustomStringConvertible, ExpressibleByArrayLiteral {

    public private(set) var value: [T]

    public init(repeating: T, count: Int) {
        self.init(value: [T](repeating: repeating, count: count))
    }

    public init(arrayLiteral elements: T...) {
        self.init(value: elements)
    }

    public init(value: [T]) {
        self.value = value
    }

    public var description: String {
        return self.value.description
    }

    public var hashValue : Int {
        // Modified DJB hash function using abs
        return self.value.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1.absolute())
        }
    }
    public static func ==(lhs: Vector<T>, rhs: Vector<T>) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        for i in 0..<lhs.count {
            if lhs[i] == rhs[i] {
                continue
            }
            return false
        }
        return true
    }

    public subscript(index: Int) -> T {
        get {
            return self.value[index]
        }
        set {
            self.value[index] = newValue
        }
    }

    public var count: Int {
        get {
            return self.value.count
        }
    }

    public func makeIterator() -> AnyIterator<T> {
        var index = 0
        return AnyIterator {
            let nextIndex = index
            guard nextIndex < self.count else {
                return nil
            }
            index += 1
            return self[nextIndex]
        }
    }

    public mutating func remove(at: Int) {
        self.value.remove(at: at)
    }

    public func add(_ other: Vector<T>) -> Vector<T> {
        let m = self.count <= other.count ? self.count : other.count
        var sum: Vector<T> = Vector<T>(repeating: 0, count:m)
        for i in 0..<m {
            sum[i] = self[i] + other[i]
        }
        return sum
    }

    public func subtract(_ other: Vector<T>) -> Vector<T> {
        let m = self.count <= other.count ? self.count : other.count
        var sum: Vector<T> = Vector<T>(repeating: 0, count:m)
        for i in 0..<m {
            sum[i] = self[i] - other[i]
        }
        return sum
    }

    public func add(_ scalar: T) -> Vector<T> {
        return Vector<T>(value: self.map {
            return $0 + scalar
        })
    }

    public func subtract(_ scalar: T) -> Vector<T> {
        return Vector<T>(value: self.map {
            return $0 - scalar
        })
    }

    public func mult(_ scalar: T) -> Vector<T> {
        return Vector<T>(value: self.map {
            return $0 * scalar
        })
    }

    public func mult(_ other: Vector<T>) throws -> Vector<T> {
        if self.count != other.count {
            throw ArrayError.differentSizes(count1: self.count, count2: other.count)
        }
        var ab = self
        for i in 0..<ab.count {
            ab[i] *= other[i]
        }
        return ab
    }

    public func prod() -> T {
        var p: T = 1
        for i in 0..<self.count {
            p *= self[i]
        }
        return p
    }

    public func inner(_ other: Vector<T>) throws -> T {
        if self.count != other.count {
            throw ArrayError.differentSizes(count1: self.count, count2: other.count)
        }
        var sum: T = 0
        for i in 0..<self.count {
            sum += self[i] * other[i]
        }
        return sum
    }

    public func outer(_ other: Vector<T>) -> Matrix<T> {
        var m = Matrix<T>(repeating: 0, rows: self.count, cols: other.count)
        for i in 0..<self.count {
            for j in 0..<other.count {
                m[i,j] += self[i] * other[j]
            }
        }
        return m
    }

    public func div(_ scalar: T) -> Vector<T> {
        return Vector<T>(value: self.map {
            return $0 / scalar
        })
    }

    public func remainder(_ scalar: T) -> Vector<T> {
        return Vector<T>(value: self.map {
            let quotient  = $0 / scalar
            return $0 - quotient * scalar
        })
    }

    public func absolute() -> Vector<Double> {
        return Vector<Double>(value: self.map {
            return $0.absolute()
        })
    }

    public func sum() -> T {
        var sum: T = 0
        for i in 0..<self.count {
            sum += self[i]
        }
        return sum
    }

    public func dot(_ other: Vector<T>) -> T {
        let m = self.count <= other.count ? self.count : other.count
        var ret: T = 0
        for i in 0..<m {
            ret += self[i] * other[i]
        }
        return ret
    }

    public func contains(_ value: T) -> Bool {
        for i in 0..<self.count {
            if value == self[i] {
                return true
            }
        }
        return false
    }

    public func reshape(_ shape: [Int]) throws -> MultiDArray<T> {
        let m = MultiDArray<T>(self)
        return try m.reshape(shape)
    }

    public static func + (left: Vector<T>, right: Vector<T>) -> Vector<T> {
        var v = left.value
        for elem in right.value {
            v.append(elem)
        }
        return Vector<T>(value:v)
    }
}

extension Vector where T : PrimitiveNumericType {

    public init(start: T = 0, stop: T, step: T = 1) {
        var value: [T] = []
        var s = start
        while s < stop {
            value.append(s)
            s += step
        }
        self.init(value:value)
    }

    public func setdiff1d(_ other: Vector<T>) -> Vector<T> {
        var set = Set<T>(other.value)
        set = Set<T>(self.value.filter({ !set.contains($0) }))
        return Vector<T>(value:Array<T>(set).sorted())
    }
}

extension Vector where T == Complex {

    public init(value: Vector<Double>) {
        self.value = value.value.map {
            return Complex(real: $0)
        }
    }

    public init(real: [Double], imag: [Double]) throws {
        if real.count != imag.count {
            throw ArrayError.differentSizes(count1: real.count, count2: imag.count)
        }
        var value: [Complex] = []
        for i in 0..<real.count {
            value.append(Complex(real[i],imag[i]))
        }
        self.init(value: value)
    }

    public func power(_ n: Double) -> Vector {
        return Vector<T>(value: self.map {
            return $0.power(n)
        })
    }

    public func conjugate() -> Vector {
        return Vector<T>(value: self.map {
            return $0.conjugate()
        })
    }

    public func real() -> Vector<Double> {
        return Vector<Double>(value: self.map {
            return $0.real
        })
    }

    public func imag() -> Vector<Double> {
        return Vector<Double>(value: self.map {
            return $0.imag
        })
    }
}
