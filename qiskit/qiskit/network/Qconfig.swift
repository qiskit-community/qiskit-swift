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
 Quantum Experience Configuration
 */
public final class Qconfig {

    public static let BASEURL: String = "https://quantumexperience.ng.bluemix.net/api/"
    public static let CLIENT_APPLICATION: String = "qiskit-sdk-swift"

    /// Target URL
    public var url: URL
    /// User Access Token
    public var access_token: String?
    /// User User ID
    public var user_id: String?
    /// Client Application
    public var client_application: String
    /// Client email
    public var email: String? = nil
    /// Client password
    public var password: String? = nil

    public init(access_token: String? = nil,
                user_id: String? = nil,
                url: String = BASEURL,
                client_application: String = CLIENT_APPLICATION) throws {
        self.access_token = access_token
        self.user_id = user_id
        guard let u = URL(string: url) else {
            throw IBMQuantumExperienceError.invalidURL(url: url)
        }
        self.url = u
        self.client_application = client_application
    }
}
