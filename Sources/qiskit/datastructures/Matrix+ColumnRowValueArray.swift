// Copyright 2018 IBM RESEARCH. All Rights Reserved.
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

extension Matrix {
    public func columnRowValueArray() -> [[Any]] {
        var result: [[Any]] = []

        for row in 0..<rowCount {
            for column in 0..<colCount {
                result.append([column, row, self[row, column]])
            }
        }

        return result
    }
}
