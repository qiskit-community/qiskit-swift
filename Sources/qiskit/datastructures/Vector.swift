
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

    public func dot(_ other: Vector<T>) -> T {
        let m = self.count <= other.count ? self.count : other.count
        var ret: T = 0
        for i in 0..<m {
            ret += self[i] * other[i]
        }
        return ret
    }
}
