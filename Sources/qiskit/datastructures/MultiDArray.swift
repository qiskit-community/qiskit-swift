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

public struct MultiDArray<T: NumericType> : Hashable, CustomStringConvertible, ExpressibleByArrayLiteral {

    private var _value = OrderedDictionary< Vector<Int>, T>()
    public private(set) var shape: [Int] = []

    public init(repeating: T, shape: [Int]) throws {
        if shape.isEmpty {
            throw ArrayError.errorShape(shape: shape)
        }
        for v in shape {
            if v == 0 {
                if v <= 0 {
                    throw ArrayError.errorShape(shape: shape)
                }
            }
        }
        self.shape = shape
        let indexes: [[Int]] = MultiDArray<T>.getAllIndexes(self.shape)
        for index in indexes {
            self._value[Vector<Int>(value:index)] = 0
        }
    }

    public init(arrayLiteral elements: [Any]...) {
        self.init(value: elements)
    }

    public init(value: [Any]) {
        let (v,s) = MultiDArray<T>.flatten(value)
        self.shape = s
        let indexes: [[Int]] = MultiDArray<T>.getAllIndexes(self.shape)
        var i = 0
        for index in indexes {
            self._value[Vector<Int>(value:index)] = v[i]
            i += 1
        }
    }

    public init(_ m: Matrix<T>) {
        self.init(value: m.value)
    }

    public init(_ v: Vector<T>) {
        self.init(value: v.value)
    }

    private init(_ value: OrderedDictionary< Vector<Int>, T>, _ shape: [Int]) {
        self._value = value
        self.shape = shape
    }

    public var count: Int {
        return self.shape.reduce(1,{x,y in x * y})
    }

    public var isEmpty: Bool {
        return self.count == 0
    }

    public var value: [Any] {
        var index: Int = 0
        return MultiDArray<T>.getValue(&index,self._value.values, self.shape)
    }

    public var description: String {
        return self.value.description
    }

    public subscript(_ index: [Int]) -> T {
        get {
            let vector = Vector<Int>(value:index)
            let value = self._value[vector]
            precondition(value != nil, "Invalid index: \(index.description)")
            return value!
        }
        set {
            let vector = Vector<Int>(value:index)
            let value = self._value[vector]
            precondition(value != nil, "Invalid index: \(index.description)")
            self._value[vector] = newValue
        }
    }

    public var hashValue : Int {
        // Modified DJB hash function using abs
        var hash = 23
        var h = self._value.values.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1.absolute())
        }
        hash = hash &* 31 &+ h
        h = self.shape.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1.absolute())
        }
        return hash &* 31 &+ h
    }

    public static func ==(lhs: MultiDArray<T>, rhs: MultiDArray<T>) -> Bool {
        return lhs.shape == rhs.shape && lhs._value.values == rhs._value.values
    }

    public func reshape(_ shape: [Int]) throws -> MultiDArray<T> {
        if shape.isEmpty {
            throw ArrayError.errorReshape(count: self.count, shape: shape)
        }
        let count = shape.reduce(1,{ x,y in x * y})
        if self.count != count {
            throw ArrayError.errorReshape(count: self.count, shape: shape)
        }
        for value in shape {
            if value == 0 {
                throw ArrayError.errorReshape(count: self.count, shape: shape)
            }
        }
        var values = self._value.values
        var value = OrderedDictionary< Vector<Int>, T>()
        let indexes: [[Int]] = MultiDArray<T>.getAllIndexes(shape)
        var i = 0
        for index in indexes {
            value[Vector<Int>(value:index)] = values[i]
            i += 1
        }
        return MultiDArray<T>(value,shape)
    }

    public func diagonal(axis1: Int = 0, axis2: Int = 1) throws -> MultiDArray<T> {
        if axis1 >= axis2 {
            throw ArrayError.errorAxis(axis1: axis1, axis2: axis2)
        }
        if axis1 >= self.shape.count || axis2 >= shape.count {
            throw ArrayError.errorAxisForShape(axis1: axis1, axis2: axis2, shape: self.shape)
        }
        var diag = OrderedDictionary<Vector<Int>,[T]>()
        for index in self._value.keys {
            if index[axis1] == index[axis2] {
                let newValue = index.value.enumerated().filter({axis1 != $0.offset && axis2 != $0.offset}).map({ $0.element })
                let newIndex = Vector<Int>(value:newValue)
                if var value = diag[newIndex] {
                    value.append(self[index.value])
                    diag[newIndex] = value
                }
                else {
                    diag[newIndex] = [self[index.value]]
                }
            }
        }
        var newShape = self.shape.enumerated().filter({axis1 != $0.offset && axis2 != $0.offset}).map({ $0.element })
        var values: [T] = []
        for (i,v) in diag.values.enumerated() {
            values.append(contentsOf: v)
            if i == 0 {
                newShape.append(v.count)
            }
        }
        let indexes: [[Int]] = MultiDArray<T>.getAllIndexes(newShape)
        var valuesDict = OrderedDictionary<Vector<Int>,T>()
        for (i,value) in values.enumerated() {
            valuesDict[Vector<Int>(value:indexes[i])] = value
        }
        return MultiDArray(valuesDict,newShape)
    }

    public func trace(axis1: Int = 0, axis2: Int = 1) throws -> MultiDArray<T> {
        let m = try self.diagonal(axis1: axis1, axis2: axis2)
        var trace = OrderedDictionary<Vector<Int>,T>()
        for index in m._value.keys {
            var newIndex = index
            newIndex.remove(at: newIndex.count-1)
            if var value = trace[newIndex] {
                value += m[index.value]
                trace[newIndex] = value
            }
            else {
                trace[newIndex] = m[index.value]
            }
        }
        var newShape = m.shape
        newShape.remove(at: newShape.count-1)
        var values: [T] = []
        for v in trace.values {
            values.append(v)
        }
        let indexes: [[Int]] = MultiDArray<T>.getAllIndexes(newShape)
        var valuesDict = OrderedDictionary<Vector<Int>,T>()
        for (i,value) in values.enumerated() {
            valuesDict[Vector<Int>(value:indexes[i])] = value
        }
        return MultiDArray(valuesDict,newShape)
    }

    private static func getAllIndexes(_ shape: [Int]) -> [[Int]] {
        var indexes: [[Int]] = []
        if let count = shape.first {
            let subIndexes = MultiDArray<T>.getAllIndexes(Array(shape[1...]))
            for i in 0..<count {
                if subIndexes.isEmpty {
                    indexes.append([i])
                    continue
                }
                for subIndex in subIndexes {
                    var v = [i]
                    v.append(contentsOf:subIndex)
                    indexes.append(v)
                }
            }
        }
        return indexes
    }

    private static func flatten(_ m: [Any]) -> ([T],[Int]) {
        if let v = m as? [T] {
            return (v,[v.count])
        }
        var shape = [m.count]
        var row: [T] = []
        for (i,r) in m.enumerated() {
            guard let rAny = r as? [Any] else {
                continue
            }
            let (vAny,s) = MultiDArray<T>.flatten(rAny)
            row.append(contentsOf:vAny)
            if i == 0 {
                shape.append(contentsOf:s)
            }
        }
        return (row,shape)
    }

    private static func getValue(_ index: inout Int, _ vector: [T], _ shape: [Int]) -> [Any] {
        if shape.count == 0 {
            return []
        }
        if shape.count == 1 {
            var row: [T] = []
            for _ in 0..<shape[0] {
                row.append(vector[index])
                index += 1
            }
            return row
        }
        var row: [Any] = []
        for _ in 0..<shape[0] {
            row.append(MultiDArray<T>.getValue(&index,vector, Array(shape[1...])))
        }
        return row
    }
}
