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
#if os(Linux)
import Dispatch
#endif

final class Credentials {

    /**
     Configuration setted to connect with QX Platform
     */
    let config: Qconfig
    private let token_unique: String?
    private(set) var data_credentials: [String:Any] = [:]
    
    init(_ token: String?,
         _ config: Qconfig? = nil) throws {
        self.token_unique = token
        if let c = config {
            self.config = c
        }
        else {
            self.config = try Qconfig()
        }
    }

    func initialize(_ request: Request,
                            _ responseHandler: @escaping ((_:IBMQuantumExperienceError?) -> Void)) {
        if self.token_unique != nil {
            self.obtain_token(request) { (error) -> Void in
                responseHandler(error)
            }
        }
        else if let access_token = self.config.access_token {
            self.set_token(access_token)
            if let user_id = self.config.user_id {
                self.set_user_id(user_id)
            }
            DispatchQueue.main.async {
                responseHandler(nil)
            }
        }
        else {
            self.obtain_token(request) { (error) -> Void in
                responseHandler(error)
            }
        }
    }

    /**
     Get Authenticated Token to connect with QX Platform
     */
    public func get_token() -> String? {
        return self.data_credentials["id"] as? String
    }

    /**
     Get User Id in QX Platform
     */
    public func get_user_id() -> String? {
        return self.data_credentials["userId"] as? String
    }

    /**
     Set Access Token to connect with QX Platform API
     */
    public func set_token(_ access_token: String) {
        self.data_credentials["id"] = access_token
    }

    /**
     Set User Id to connect with QX Platform API
     */
    public func set_user_id(_ user_id: String) {
        self.data_credentials["userId"] = user_id
    }

    /**
     Obtain the token to access to QX Platform.

     Raises:
        CredentialsError: when token is invalid.
     */
    func obtain_token(_ request: Request, _ responseHandler: @escaping ((_:IBMQuantumExperienceError?) -> Void)) {
        if let token = self.token_unique {
            let path = "users/loginWithToken"
            guard let url = URL(string: path, relativeTo: self.config.url) else {
                DispatchQueue.main.async {
                    responseHandler(IBMQuantumExperienceError.invalidURL(url: "\(self.config.url.description)/\(path)"))
                }
                return
            }
            request.postInternal(url: url, data: ["apiToken": token]) { (out, error) -> Void in
                if error != nil {
                    responseHandler(error)
                    return
                }
                guard let json = out as? [String:Any] else {
                    responseHandler(IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                self.data_credentials = json
                if self.get_token() == nil {
                    responseHandler(IBMQuantumExperienceError.missingTokenId)
                    return
                }
                responseHandler(nil)
            }
            return
        }
        else if let email = self.config.email,
            let password = self.config.password {
            let path = "users/login"
            guard let url = URL(string: path, relativeTo: self.config.url) else {
                DispatchQueue.main.async {
                    responseHandler(IBMQuantumExperienceError.invalidURL(url: "\(self.config.url.description)/\(path)"))
                }
                return
            }
            request.postInternal(url: url, data: ["email": email, "password" : password]) { (out, error) -> Void in
                if error != nil {
                    responseHandler(error)
                    return
                }
                guard let json = out as? [String:Any] else {
                    responseHandler(IBMQuantumExperienceError.invalidResponseData)
                    return
                }
                self.data_credentials = json
                if self.get_token() == nil {
                    responseHandler(IBMQuantumExperienceError.missingTokenId)
                    return
                }
                responseHandler(nil)
            }
            return
        }
        else {
            DispatchQueue.main.async {
                responseHandler(IBMQuantumExperienceError.missingTokenId)
            }
            return
        }
    }
}
