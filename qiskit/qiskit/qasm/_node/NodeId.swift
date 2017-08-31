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

/*
 Node for an OPENQASM id.
 The node has no children but has fields name, line, and file.
 There is a flag is_bit that is set when XXXXX to help with scoping.
 */
@objc public final class NodeId: Node, NodeRealValueProtocol {

    public private(set) var _name: String = ""
    public private(set) var line: Int = 0
    public private(set) var file: String = ""
    public private(set) var index: Int = 0  // FIXME where does the index come from?
    public private(set) var is_bit: Bool = false
    
    public init(identifier: String, line: Int) {
        self._name = identifier
        self.line = line
        self.file = "" // FIXME find the name
        self.is_bit = false
    }
    
    public override var type: NodeType {
        return .N_ID
    }
    
    public override var name: String {
        return _name
    }

    public override func qasm(_ prec: Int) -> String {
        let qasm: String = _name
        return qasm
    }

    public func real(_ nested_scope: [[String:NodeRealValueProtocol]]?) throws -> Double {
        guard let scope = nested_scope else {
            throw QasmException.errorLocalParameter(qasm: self.qasm(15))
        }
        guard let last = scope.last else {
            throw QasmException.errorLocalParameter(qasm: self.qasm(15))
        }
        guard let arg = last[self.name] else {
            throw QasmException.errorLocalParameter(qasm: self.qasm(15))
        }
        let endIndex: Int = scope.count - 1
        return try arg.real(Array(scope[0..<endIndex]))
    }
}
