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

    public let data: String
    
    init(filename: String) throws {
        self.data  = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)
    }
    
    init(data: String) {
        self.data = data
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

}
