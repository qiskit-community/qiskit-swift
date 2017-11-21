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

public protocol NumericType: ExpressibleByIntegerLiteral {
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
    static func +=(lhs: inout Self, rhs: Self)
    static func -=(lhs: inout Self, rhs: Self)
    static func *=(lhs: inout Self, rhs: Self)
    static func /=(lhs: inout Self, rhs: Self)
}

public protocol SignedNumericType: NumericType {
    static prefix func -(value: Self) -> Self
}

public protocol FloatingPointType: SignedNumericType {
}

extension Int    : SignedNumericType { }
extension Int8   : SignedNumericType { }
extension Int16  : SignedNumericType { }
extension Int32  : SignedNumericType { }
extension Int64  : SignedNumericType { }
extension UInt   : NumericType { }
extension UInt8  : NumericType { }
extension UInt16 : NumericType { }
extension UInt32 : NumericType { }
extension UInt64 : NumericType { }
extension Float32 : FloatingPointType { }
extension Float64 : FloatingPointType { }
