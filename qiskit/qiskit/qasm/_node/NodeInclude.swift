//
//  NodeInclude.swift
//  qiskit
//
//  Created by Joe Ligman on 6/8/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

@objc public final class NodeInclude: Node {

    public var expandedInclude: String = ""
    static private let INCLUDE: String = "include"

    public init(file: String) {
        super.init()
        let qasm: String = "include \(file);"
        do {
            expandedInclude = try self.expandIncludes(qasm)
            debugPrint(expandedInclude)
        } catch {
           // FIXME
            debugPrint("failed to load header")
        }
    }
    
    public override var type: NodeType {
        return .N_INCLUDE
    }
    
    public override func qasm() -> String {
        return expandedInclude
    }
    
    private func eliminateCommments(_ qasm: String) -> String {
        var lines: [String] = []
        for line in qasm.components(separatedBy: CharacterSet.newlines) {
            if let range = line.range(of: "//") {
                let start = range.lowerBound
                let newLine = line[line.startIndex..<start]
                if !newLine.isEmpty {
                    lines.append(newLine)
                }
            }
            else {
                lines.append(line)
            }
        }
        return lines.joined()
    }
    
    
    private func expandIncludes(_ qasm: String) throws -> String {
        var qasmData = eliminateCommments(qasm)
        repeat {
            guard let includRange = qasmData.range(of: NodeInclude.INCLUDE) else {
                return qasmData
            }
            guard let startRange = qasmData.range(of: "\"", options: String.CompareOptions.literal, range: includRange.upperBound..<qasmData.endIndex) else {
                return qasmData
            }
            guard let endRange = qasmData.range(of: "\"", options: String.CompareOptions.literal, range: startRange.upperBound..<qasmData.endIndex) else {
                return qasmData
            }
            guard let endInclude = qasmData.range(of: ";", options: String.CompareOptions.literal, range: endRange.upperBound..<qasmData.endIndex) else {
                return qasmData
            }
            let start = qasmData.index(startRange.lowerBound, offsetBy: 1)
            let name = qasmData.substring(with: start..<endRange.lowerBound)
            let nameComponents = name.components(separatedBy: ".")
            if nameComponents.count != 2 {
                return qasmData
            }
            let includeData = try self.loadLib(nameComponents[0],nameComponents[1])
            qasmData.replaceSubrange(includRange.lowerBound..<endInclude.upperBound, with: includeData)
        }
            while true
    }
    
    private func loadLib(_ name: String, _ ext: String) throws -> String {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.path(forResource: "libs", ofType: "bundle") else {
            throw QasmException.error(msg: "Bundle qasm not found")
        }
        guard let libsBundle = Bundle(path: path) else {
            throw QasmException.error(msg: "Bundle not found \(path)")
        }
        guard let url = libsBundle.url(forResource: name, withExtension: ext) else {
            throw QasmException.error(msg: "Bundle \(name).\(ext) path not found")
        }
        return eliminateCommments(try String(contentsOf: url, encoding: .utf8))
    }
}
