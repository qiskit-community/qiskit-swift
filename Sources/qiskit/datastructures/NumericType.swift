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

public protocol NumericType: ExpressibleByIntegerLiteral, Hashable {
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    static func +=(lhs: inout Self, rhs: Self)
    static func -=(lhs: inout Self, rhs: Self)
    static func *=(lhs: inout Self, rhs: Self)
    static func /=(lhs: inout Self, rhs: Self)
    static func ==(lhs: Self, rhs: Self) -> Bool
    func absolute() -> Double
}

public protocol PrimitiveNumericType: NumericType, Comparable {
}

public protocol SignedNumericType: PrimitiveNumericType {
    static prefix func -(value: Self) -> Self
}

public protocol UnsignedNumericType: PrimitiveNumericType {
}

public protocol FloatingPointType: SignedNumericType {
}

extension Int    : SignedNumericType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
extension Int8   : SignedNumericType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
extension Int16  : SignedNumericType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
extension Int32  : SignedNumericType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
extension Int64  : SignedNumericType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
extension UInt   : UnsignedNumericType {
    public func absolute() -> Double {
        return Double(self)
    }
}
extension UInt8  : UnsignedNumericType {
    public func absolute() -> Double {
        return Double(self)
    }
}
extension UInt16 : UnsignedNumericType {
    public func absolute() -> Double {
        return Double(self)
    }
}
extension UInt32 : UnsignedNumericType {
    public func absolute() -> Double {
        return Double(self)
    }
}
extension UInt64 : UnsignedNumericType {
    public func absolute() -> Double {
        return Double(self)
    }
}
extension Float32 : FloatingPointType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
extension Float64 : FloatingPointType {
    public func absolute() -> Double {
        return Double(abs(self))
    }
}
