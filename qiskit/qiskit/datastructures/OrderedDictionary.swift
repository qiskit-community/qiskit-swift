//
//  OrderedDictionary.swift
//  qiskit
//
//  Created by Manoel Marques on 6/3/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

struct OrderedDictionary<KeyType: Hashable, ValueType>: CustomStringConvertible {

    public private(set) var keys: [KeyType] = []
    private var values: [KeyType:ValueType] = [:]

    var count: Int {
        return self.keys.count;
    }

    subscript(key: KeyType) -> ValueType? {
        get {
            return self.values[key]
        }
        set(newValue) {
            if newValue == nil {
                if self.values[key] != nil {
                    self.values.removeValue(forKey: key)
                    self.keys = self.keys.filter {$0 != key}
                }
            }
            else {
                if nil == self.values.updateValue(newValue!, forKey: key) {
                    self.keys.append(key)
                }
            }
        }
    }

    init() {
    }

    func value(_ at: Int) -> ValueType {
        let key = self.keys[at]
        return self.values[key]!
    }

    var description: String {
        var arr: [String] = []
        for key in self.keys {
            if let value = self[key] {
                arr.append("\"\(key)\": \"\(value)\"")
            }
        }
        return "[" + arr.joined(separator: ",") + "]"
    }
}
