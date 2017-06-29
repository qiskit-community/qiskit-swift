//
//  Qasm.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import qiskitPrivate

final class Qasm {

    static private let INCLUDE: String = "include"

    private(set) var data: String = ""

    init(filename: String) throws {
        self.data  = try self.expandIncludes(try String(contentsOfFile: filename, encoding: String.Encoding.utf8))
    }

    init(data: String) throws {
        self.data = try self.expandIncludes(data)
    }

    func parse() throws -> NodeMainProgram {
        var root: NodeMainProgram? = nil
        var errorMsg: String? = nil
        SyncLock.synchronized(Qasm.self) {
            let semaphore = DispatchSemaphore(value: 0)
            let buf: YY_BUFFER_STATE = yy_scan_string(self.data)

            ParseSuccessBlock = { (n: NSObject?) -> Void in
                defer {
                    semaphore.signal()
                }
                if let node = n as? NodeMainProgram {
                    root = node
                }
            }

            ParseFailBlock = { (message: String?) -> Void in
                defer {
                    semaphore.signal()
                }
                if let msg = message {
                    errorMsg = msg
                } else {
                    errorMsg = "Unknown Error"
                }
            }
            
            yyparse()
            yy_delete_buffer(buf)
            semaphore.wait()
        }
        if let error = errorMsg {
            throw QISKitException.parserError(msg: error)
        }
        if root == nil {
            throw QISKitException.parserError(msg: "Missing root node")
        }
        return root!
    }

    private static func eliminateCommments(_ qasm: String) -> String {
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
        var qasmData = Qasm.eliminateCommments(qasm)
        repeat {
            guard let includRange = qasmData.range(of: Qasm.INCLUDE) else {
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
        return Qasm.eliminateCommments(try String(contentsOf: url, encoding: .utf8))
    }
}
