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

/**
 Exception for errors raised by the Materix object.
 */
public enum MatrixError: LocalizedError, CustomStringConvertible {
    case rowStartOutOfBounds(row: Int)
    case rowEndOutOfBounds(row: Int)
    case rowsOutOfBounds(rowStart: Int,rowEnd: Int)
    case colStartOutOfBounds(col: Int)
    case colEndOutOfBounds(col: Int)
    case colsOutOfBounds(colStart: Int,colEnd: Int)
    case detSquare
    case detEmpty
    case sameShape

    public var errorDescription: String? {
        return self.description
    }
    public var description: String {
        switch self {
        case .rowStartOutOfBounds(let row):
            return "Row start index out of bounds: \(row)"
        case .rowEndOutOfBounds(let row):
            return "Row end index out of bounds: \(row)"
        case .rowsOutOfBounds(let rowStart, let rowEnd):
            return "Row start,end indexes out of bounds: (\(rowStart),\(rowEnd))"
        case .colStartOutOfBounds(let col):
            return "Col start index out of bounds: \(col)"
        case .colEndOutOfBounds(let col):
            return "Col end index out of bounds: \(col)"
        case .colsOutOfBounds(let colStart, let colEnd):
            return "Row start,end indexes out of bounds: (\(colStart),\(colEnd))"
        case .detSquare:
            return "Determinant of a non-square matrix"
        case .detEmpty:
            return "Determinant of an empty matrix"
        case .sameShape:
            return "Matrices must have same number of rows and columns"
        }
    }
}
