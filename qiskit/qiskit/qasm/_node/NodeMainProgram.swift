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

@objc public final class NodeMainProgram: Node {
    
    public let magic: Node?
    public let incld: Node?
    public let program: Node?
    
    public init(magic: Node?, incld: Node?, program: Node?) {
        self.magic = magic
        self.incld = incld
        self.program = program
    }
    
    public override var type: NodeType {
        return .N_MAINPROGRAM
    }
    
    public override func qasm() -> String {
        var qasm: String = magic?.qasm() ?? ""
        qasm += "\(incld?.qasm() ?? "")\n"
        qasm += "\(program?.qasm() ?? "")\n"
        return qasm
    }
}
