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
