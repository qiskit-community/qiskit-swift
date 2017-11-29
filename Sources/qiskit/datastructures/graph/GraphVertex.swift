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

final class GraphVertex<VertexDataType: GraphDataCopying> : Hashable {

    public let key: Int
    public var data: VertexDataType? = nil
    public var neighbors: [Int] {
        get {
            return self._neighbors.sorted()
        }
    }
    public var hashValue : Int {
        get {
            return self.key.hashValue
        }
    }
    private var _neighbors: Set<Int> = []

    public init(_ key: Int) {
        self.key = key
    }

    func addNeighbor(_ key: Int) {
        self._neighbors.update(with: key)
    }

    func removeNeighbor(_ key: Int) {
        self._neighbors.remove(key)
    }

    public func copy() -> GraphVertex<VertexDataType> {
        let copy = GraphVertex<VertexDataType>(self.key)
        if self.data != nil {
            let d = self.data!.copy() as! VertexDataType
            copy.data = d
        }
        copy._neighbors =  self._neighbors
        return copy
    }

    public static func ==(lhs: GraphVertex<VertexDataType>, rhs: GraphVertex<VertexDataType>) -> Bool {
        return lhs.key == rhs.key
    }
}

