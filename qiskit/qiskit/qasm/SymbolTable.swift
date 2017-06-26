//
//  SymbolTable.swift
//  qiskit
//
//  Created by Joe Ligman on 6/20/17.
//  Copyright © 2017 IBM. All rights reserved.
//

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

