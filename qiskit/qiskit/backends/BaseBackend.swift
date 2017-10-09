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

/**
 This module implements the abstract base class for backend modules.
 To create add-on backend modules subclass the Backend class in this module.
 Doing so requires that the required backend interface is implemented.
 */
public class BaseBackend {

    public let qobj: [String:Any]
    public var configuration : [String:Any] {
        return self._configuration
    }
    var _configuration : [String:Any] = [:]

    public required init(_ qobj: [String:Any]) {
        if type(of: self) == BaseBackend.self {
            fatalError("Abstract class instantiation.")
        }
        self.qobj = qobj
    }

    public func run(_ silent: Bool = true) throws -> Result {
        preconditionFailure("run not implemented")
    }
}
