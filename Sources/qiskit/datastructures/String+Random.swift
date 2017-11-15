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

extension String {
    static func randomAlphanumeric(length: Int) -> String {
        struct StaticVars {
            static let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            static let lettersLength = UInt32(letters.count)
        }
        var array = [Character](repeating: " ", count: length)
        let random = Random(time(nil))
        for i in 0..<length {
            let pos = Int(random.random() * Double(StaticVars.lettersLength))
            let index = StaticVars.letters.index(StaticVars.letters.startIndex, offsetBy: pos)
            array[i] = StaticVars.letters[index]
        }
        return String(array)
    }
}
