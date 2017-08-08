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

final class GraphEdge<EdgeDataType: NSCopying> {

    public var data: EdgeDataType? = nil
    public let source: Int
    public let neighbor: Int

    init(_ source: Int, _ neighbor: Int) {
        self.source = source
        self.neighbor = neighbor
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = GraphEdge<EdgeDataType>(self.source,self.neighbor)
        if self.data != nil {
            let d = self.data!.copy(with: zone) as! EdgeDataType
            copy.data = d
        }
        return copy
    }
}
