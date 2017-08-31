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

class CircuitVertexData: NSCopying {
    let type: String

    init(type: String) {
        if type(of: self) == CircuitVertexData.self {
            fatalError("Abstract class instantiation.")
        }
        self.type = type
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        preconditionFailure("copy not implemented")
    }
}

class CircuitVertexInOutData: CircuitVertexData {
    var name: RegBit

    init(name: RegBit, type: String) {
        if type(of: self) == CircuitVertexInOutData.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = name
        super.init(type: type)
    }
}

final class CircuitVertexInData: CircuitVertexInOutData {

    init(_ name: RegBit) {
        super.init(name: name, type: "in")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        return CircuitVertexInData(self.name)
    }
}

final class CircuitVertexOutData: CircuitVertexInOutData {

    init(_ name: RegBit) {
        super.init(name: name, type: "out")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        return CircuitVertexOutData(self.name)
    }
}

final class CircuitVertexOpData: CircuitVertexData {
    var name: String
    var qargs: [RegBit]
    var cargs: [RegBit]
    var params: [String]
    var condition: RegBit?

    init(_ name: String,_ qargs: [RegBit], _ cargs: [RegBit], _ params: [String], _ condition: RegBit?) {
        self.name = name
        self.qargs = qargs
        self.cargs = cargs
        self.params = params
        self.condition = condition
        super.init(type: "op")
    }

    public override func copy(with zone: NSZone? = nil) -> Any {
        return CircuitVertexOpData(self.name,self.qargs,self.cargs,self.params,self.condition)
    }
}

