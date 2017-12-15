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

public struct SymbolicValue: ExpressibleByFloatLiteral, Comparable, Hashable {

    public typealias FloatLiteralType = Swift.FloatLiteralType

    public static let pi: SymbolicValue = SymbolicValue(Double.pi)

    public let value: FloatLiteralType

    public init() {
        self.value = 0.0
    }
    public init(_ value: Swift.FloatLiteralType) {
        self.value = value
    }
    public init(floatLiteral value: FloatLiteralType) {
        self.value = value
    }
    public var hashValue : Int {
        get {
            return self.value.hashValue
        }
    }
    public static func < (left: SymbolicValue, right: SymbolicValue) -> Bool {
        return left.value < right.value
    }
    public static func <= (left: SymbolicValue, right: SymbolicValue) -> Bool {
        return left.value <= right.value
    }
    public static func >= (left: SymbolicValue, right: SymbolicValue) -> Bool {
        return left.value >= right.value
    }
    public static func > (left: SymbolicValue, right: SymbolicValue) -> Bool {
        return left.value > right.value
    }
    public static func == (left: SymbolicValue, right:SymbolicValue) -> Bool {
        return left.value == right.value
    }
    public func format(_ precision: Int) -> String {
        if self.value == Double.pi {
            return "pi"
        }
        if self.value == 0.0 {
            return "0"
        }
        return self.value.format(precision)
    }
    public func truncatingRemainder(dividingBy other: SymbolicValue) -> SymbolicValue {
        return SymbolicValue(self.value.truncatingRemainder(dividingBy: other.value))
    }
    public func add(_ n: SymbolicValue) -> SymbolicValue {
        return SymbolicValue(self.value + n.value)
    }
    public func add(_ n: FloatLiteralType) -> SymbolicValue {
        return SymbolicValue(self.value + n)
    }
    public func subtract(_ n: SymbolicValue) -> SymbolicValue {
       return SymbolicValue(self.value - n.value)
    }
    public func subtract(_ n: FloatLiteralType) -> SymbolicValue {
        return SymbolicValue(self.value - n)
    }
    public func multiply(_ n: SymbolicValue) -> SymbolicValue {
        return SymbolicValue(self.value * n.value)
    }
    public func multiply(_ n: FloatLiteralType) -> SymbolicValue {
        return SymbolicValue(self.value * n)
    }
    public func divide(_ n: SymbolicValue) -> SymbolicValue {
        return SymbolicValue(self.value / n.value)
    }
    public func divide(_ n: FloatLiteralType) -> SymbolicValue {
        return SymbolicValue(self.value / n)
    }
    public func squareRoot() -> SymbolicValue {
        return SymbolicValue(self.value.squareRoot())
    }
}

public func abs(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(abs(value.value))
}
public func sin(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(sin(value.value))
}
public func asin(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(asin(value.value))
}
public func acos(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(acos(value.value))
}
public func tan(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(tan(value.value))
}
public func atan(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(atan(value.value))
}
public func cos(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(cos(value.value))
}
public func exp(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(exp(value.value))
}
public func log(_ value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(log(value.value))
}
public func pow(_ left: SymbolicValue, _ right: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(pow(left.value,right.value))
}
public prefix func - (value: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(-value.value)
}
public func + (left: SymbolicValue,  right: SymbolicValue) -> SymbolicValue {
    return left.add(right)
}
public func + (left: SymbolicValue,  right: FloatLiteralType) -> SymbolicValue {
    return left.add(right)
}
public func + (left: FloatLiteralType, right: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(left).add(right)
}
public func - (left: SymbolicValue, right: SymbolicValue) -> SymbolicValue {
    return left.subtract(right)
}
public func - (left: SymbolicValue, right: FloatLiteralType) -> SymbolicValue {
    return left.subtract(right)
}
public func - (left: FloatLiteralType, right: SymbolicValue) -> SymbolicValue {
    return SymbolicValue(left).subtract(right)
}
public func * (left: SymbolicValue, right: SymbolicValue) -> SymbolicValue {
    return left.multiply(right)
}
public func * (left: SymbolicValue, right: FloatLiteralType) -> SymbolicValue {
    return left.multiply(right)
}
public func / (left: SymbolicValue, right: SymbolicValue) -> SymbolicValue {
    return left.divide(right)
}
public func / (left: SymbolicValue, right: FloatLiteralType) -> SymbolicValue {
    return left.divide(right)
}
public func > (left: SymbolicValue, right: FloatLiteralType) -> Bool {
    return left.value > right
}
public func < (left: SymbolicValue, right: FloatLiteralType) -> Bool {
    return left.value < right
}
