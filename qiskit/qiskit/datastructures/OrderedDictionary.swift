//
//  OrderedDictionary.swift
//  qiskit
//
//  Created by Manoel Marques on 6/3/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

public struct OrderedDictionary<KeyType: Hashable, ValueType>: Sequence, CustomStringConvertible {

    public private(set) var keys: [KeyType] = []
    public private(set) var values: [KeyType:ValueType] = [:]

    public var count: Int {
        return self.keys.count;
    }

    public subscript(key: KeyType) -> ValueType? {
        get {
            return self.values[key]
        }
        set(newValue) {
            if newValue == nil {
                self.removeValue(forKey: key)
            }
            else {
                if nil == self.values.updateValue(newValue!, forKey: key) {
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
        if self.values[forKey] != nil {
            self.values.removeValue(forKey: forKey)
            self.keys = self.keys.filter {$0 != forKey}
        }
    }

    public func value(_ at: Int) -> ValueType {
        let key = self.keys[at]
        return self.values[key]!
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
