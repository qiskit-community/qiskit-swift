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

public struct OrderedDictionary<KeyType: Hashable, ValueType>: Sequence, CustomStringConvertible {

    public private(set) var keys: [KeyType] = []
    private var keyValues: [KeyType:ValueType] = [:]

    public var count: Int {
        return self.keys.count;
    }

    public var values: [ValueType] {
        var vals: [ValueType] = []
        for key in self.keys {
            if let value = self[key] {
                vals.append(value)
            }
        }
        return vals
    }

    public subscript(key: KeyType) -> ValueType? {
        get {
            return self.keyValues[key]
        }
        set(newValue) {
            if newValue == nil {
                self.removeValue(forKey: key)
            }
            else {
                if nil == self.keyValues.updateValue(newValue!, forKey: key) {
                    self.keys.append(key)
                }
            }
        }
    }

    public init() {
    }

    public func makeIterator() -> AnyIterator<(KeyType,ValueType)> {
        var index = 0
        return AnyIterator {
            let nextIndex = index
            guard nextIndex < self.count else {
                return nil
            }
            index += 1
            return (self.keys[nextIndex],self.value(nextIndex))
        }
    }

    public mutating func removeValue(forKey: KeyType) {
        if self.keyValues[forKey] != nil {
            self.keyValues.removeValue(forKey: forKey)
            self.keys = self.keys.filter {$0 != forKey}
        }
    }

    public func value(_ at: Int) -> ValueType {
        let key = self.keys[at]
        return self.keyValues[key]!
    }

    public var description: String {
        var arr: [String] = []
        for key in self.keys {
            if let value = self[key] {
                arr.append("\"\(key)\": \"\(value)\"")
            }
        }
        return "[" + arr.joined(separator: " ,") + "]"
    }
}
