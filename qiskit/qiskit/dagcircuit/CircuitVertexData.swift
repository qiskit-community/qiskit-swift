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

class CircuitVertexData: GraphDataCopying {
    let type: String

    init(_ type: String) {
        if Swift.type(of: self) == CircuitVertexData.self {
            fatalError("Abstract class instantiation.")
        }
        self.type = type
    }

    init(_ instance: CircuitVertexData) {
        if Swift.type(of: self) == CircuitVertexData.self {
            fatalError("Abstract class instantiation.")
        }
        self.type = instance.type
    }

    func copy() -> GraphDataCopying {
        fatalError("copy Abstract class not implemented.")
    }
}

class CircuitVertexInOutData: CircuitVertexData {
    var name: RegBit

    init(name: RegBit, type: String) {
        if Swift.type(of: self) == CircuitVertexInOutData.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = name
        super.init(type)
    }

    init(_ instance: CircuitVertexInOutData) {
        if Swift.type(of: self) == CircuitVertexInOutData.self {
            fatalError("Abstract class instantiation.")
        }
        self.name = instance.name
        super.init(instance)
    }

    override func copy() -> GraphDataCopying {
        fatalError("copy Abstract class not implemented.")
    }
}

final class CircuitVertexInData: CircuitVertexInOutData {

    init(_ name: RegBit) {
        super.init(name: name, type: "in")
    }

    init(_ instance: CircuitVertexInData) {
        super.init(instance)
    }

    override func copy() -> GraphDataCopying {
        return CircuitVertexInData(self)
    }
}

final class CircuitVertexOutData: CircuitVertexInOutData {

    init(_ name: RegBit) {
        super.init(name: name, type: "out")
    }

    init(_ instance: CircuitVertexOutData) {
        super.init(instance)
    }

    override func copy() -> GraphDataCopying {
        return CircuitVertexOutData(self)
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
        super.init("op")
    }

    init(_ instance: CircuitVertexOpData) {
        self.name = instance.name
        self.qargs = instance.qargs
        self.cargs = instance.cargs
        self.params = instance.params
        self.condition = instance.condition
        super.init(instance)
    }

    override func copy() -> GraphDataCopying {
        return CircuitVertexOpData(self)
    }
}
