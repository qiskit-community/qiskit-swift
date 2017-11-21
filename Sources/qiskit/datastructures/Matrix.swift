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

public struct Matrix<T: NumericType> : CustomStringConvertible, ExpressibleByArrayLiteral {

    public private(set) var value: [[T]]

    public init(repeating: T, rows: Int, cols: Int) {
        self.init(value: [[T]](repeating: [T](repeating: repeating, count: cols), count: rows))
    }

    public init(arrayLiteral elements: [T]...) {
        self.init(value: elements)
    }

    private init(value: [[T]]) {
        let cols = value.isEmpty ? 0 : value[0].count
        for i in 0..<value.count {
            if cols != value[i].count {
                fatalError("Matrix must have same number of columns")
            }
        }
        self.value = value
    }

    public static func identity(_ n: Int) -> Matrix<T> {
        var m = Matrix<T>(repeating: 0, rows: n, cols: 0)
        for row in 0..<m.rowCount {
            for col in 0..<m.colCount {
                m[row,col] = row == col ? 1 : 0
            }
        }
        return m
    }

    public var description: String {
        return self.value.description
    }

    public subscript(row: Int, column: Int) -> T {
        get {
            return self.value[row][column]
        }
        set {
            self.value[row][column] = newValue
        }
    }

    public var rowCount: Int {
        get {
            return self.value.count
        }
    }

    public var colCount: Int {
        get {
            return self.value.first?.count ?? 0
        }
    }

    public func mult(_ scalar: T) -> Matrix<T> {
        var ab = self
        for i in 0..<ab.rowCount {
            for j in 0..<ab.colCount {
                ab[i,j] += self[i,j] * scalar
            }
        }
        return ab
    }

    public func dot(_ other: Matrix<T>) -> Matrix<T> {
        let m = self.rowCount
        let n = self.colCount
        let q = other.colCount

        var ab = Matrix<T>(repeating: 0, rows:m, cols:q)
        for i in 0..<m {
            for j in 0..<q {
                for k in 0..<n {
                    ab[i,j] += self[i,k] * other[k,j]
                }
            }
        }
        return ab
    }

    public func kron(_ other: Matrix<T>) -> Matrix<T> {
        let m = self.rowCount
        let n = self.colCount
        let p = other.rowCount
        let q = other.colCount

        var ab = Matrix<T>(repeating: 0, rows:m * p, cols:n * q)
        for i in 0..<m {
            for j in 0..<n {
                let da = self[i,j]
                for k in 0..<p {
                    for l in 0..<q {
                        let db = other[k,l]
                        ab[p*i + k,q*j + l] = da * db
                    }
                }
            }
        }
        return ab
    }
}
