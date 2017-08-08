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

public struct SymbolEntry {

    let name: String
    let type: NodeType
    let line: Int
    let file: String
}

extension SymbolEntry: Equatable {
    public static func == (lhs: SymbolEntry, rhs: SymbolEntry) -> Bool {
        return lhs.name == rhs.name &&
            lhs.type == rhs.type &&
            lhs.line == rhs.line &&
            lhs.file == rhs.file
    }
}

extension SymbolEntry: Hashable {
    public var hashValue: Int {
        return name.hashValue ^ type.hashValue ^ line.hashValue ^ file.hashValue
    }
}

@objc public final class SymbolTable: NSObject {
    
    private var count = 100
    private var _symbolTable = [SymbolEntry?](repeating: nil, count:100)
    
    public func exists(entry: SymbolEntry) -> Bool {
        let hash = entry.hashValue % count
        return _symbolTable[hash] == nil
    }
    
    public func insert(entry: SymbolEntry) throws {
        if exists(entry: entry) {
            throw QasmException.error(msg: "boogers")
        }
        let hash = entry.hashValue % count
        _symbolTable[hash] = entry
    }
    
    public func delete(entry: SymbolEntry) {
        let hash = entry.hashValue % count
        _symbolTable[hash] = nil
    }
    
}

