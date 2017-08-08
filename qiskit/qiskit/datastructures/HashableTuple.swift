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

public typealias TupleInt = HashableTuple<Int,Int>

public struct HashableTuple<A:Hashable,B:Hashable> : Hashable, Equatable, CustomStringConvertible {
    public let one: A
    public let two: B

    public init(_ one: A, _ two: B) {
        self.one = one
        self.two = two
    }
    public var hashValue : Int {
        get {
            return self.one.hashValue &* 31 &+ self.two.hashValue
        }
    }

    public var description: String {
        return "(\(self.one), \(self.two))"
    }

    public static func ==<A:Hashable,B:Hashable>(lhs: HashableTuple<A,B>, rhs: HashableTuple<A,B>) -> Bool {
        return lhs.one == rhs.one && lhs.two == rhs.two
    }
}
