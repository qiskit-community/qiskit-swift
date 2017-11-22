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

    public var isEmpty: Bool {
        return self.count == 0
    }

    public var isSquare: Bool {
        return self.rowCount == self.colCount
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

    public var count: Int {
        return self.rowCount * self.colCount
    }

    public var shape: (Int,Int) {
        return (self.rowCount,self.colCount)
    }

    public var rowCount: Int {
        return self.value.count
    }

    public var colCount: Int {
        return self.value.first?.count ?? 0
    }

    public mutating func removeRow(at index: Int){
        self.value.remove(at: index)
    }

    public mutating func removeCol(at index: Int){
        for i in 0..<self.rowCount {
            self.value[i].remove(at: index)
        }
    }

    public func add(_ other: Matrix<T>) -> Matrix<T> {
        let rows = self.rowCount <= other.rowCount ? self.rowCount : other.rowCount
        let cols = self.colCount <= other.colCount ? self.colCount : other.colCount
        var sum = Matrix<T>(repeating: 0, rows:rows, cols:cols)
        for row in 0..<rows {
            for col in 0..<cols {
                sum[row,col] = self[row,col] + other[row,col]
            }
        }
        return sum
    }

    public func subtract(_ other: Matrix<T>) -> Matrix<T> {
        let rows = self.rowCount <= other.rowCount ? self.rowCount : other.rowCount
        let cols = self.colCount <= other.colCount ? self.colCount : other.colCount
        var sub = Matrix<T>(repeating: 0, rows:rows, cols:cols)
        for row in 0..<rows {
            for col in 0..<cols {
                sub[row,col] = self[row,col] - other[row,col]
            }
        }
        return sub
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

    public func oneNorm() -> Double {
        var largest = 0.0
        for i in 0..<self.colCount {
            var sum = 0.0
            for j in 0..<self.rowCount {
                sum += self[j,i].absolute() // compute the column sum
            }
            if sum > largest {
                largest = sum // found a new largest column sum
            }
        }
        return largest
    }

    public func pnorm(_ p: Double) -> Double {
        if p == 1 {
            return oneNorm()
        }
        var sum = 0.0
        for i in 0..<self.rowCount {
            for j in 0..<self.colCount {
                sum += pow(self[i,j].absolute(),p)
            }
        }
        return pow(sum, 1.0/Double(p))
    }

    public func norm() -> Double {
        return self.frobeniusNorm()
    }

    public func frobeniusNorm() -> Double {
        return self.pnorm(2)
    }

    public func det() -> T {
        return Matrix.det(self)
    }

    private static func det(_ matrix: Matrix<T>) -> T {
        assert(matrix.isSquare, "Determinant of a non-square matrix")
        assert(!matrix.isEmpty, "Determinant of an empty matrix")
        if matrix.count == 1 {
            return matrix[0,0]
        }
        if matrix.count == 4 {
            return matrix[0,0] * matrix[1,1] - matrix[0,1] * matrix[1,0]
        }
        var determinant: T = 0
        var multiplier: T = 1
        let topRow = matrix.value[0]
        for (col, num) in topRow.enumerated() {
            var subMatrix = matrix
            subMatrix.removeRow(at: 0)
            subMatrix.removeCol(at: col)
            determinant += num * multiplier * Matrix.det(subMatrix)
            multiplier = -1
        }
        return determinant
    }
}
