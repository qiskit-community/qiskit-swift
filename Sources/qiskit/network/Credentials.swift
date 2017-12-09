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

public final class Credentials {

    /**
     Configuration to connect with QX Platform
     */
    var config: [String:Any]
    private let token_unique: String?
    private(set) var data_credentials: [String:Any] = [:]

    private static let config_base: [String:Any] = ["url": IBMQuantumExperience.URL_BASE]
    static let CLIENT_APPLICATION: String = "qiskit-sdk-swift"
    
    init(_ token: String?,
         _ config: [String:Any]? = nil) {
        self.token_unique = token
        if let c = config {
            self.config = c
            let u = self.config["url"] as? String
            if u == nil {
                self.config["url"] = Credentials.config_base["url"]
            }
        }
        else {
            self.config = Credentials.config_base
        }
    }

    func initialize(_ request: Request,
                            _ responseHandler: @escaping ((_:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        if self.token_unique != nil {
            return self.obtain_token(request) { (error) -> Void in
                responseHandler(error)
            }
        }
        else if let access_token = self.config["access_token"] as? String {
            self.set_token(access_token)
            if let user_id = self.config["user_id"] as? String {
                self.set_user_id(user_id)
            }
            DispatchQueue.main.async {
                responseHandler(nil)
            }
            return RequestTask()
        }
        else {
            return self.obtain_token(request) { (error) -> Void in
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
    func obtain_token(_ request: Request, _ responseHandler: @escaping ((_:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        guard let baseURLPath = self.config["url"] as? String else {
            responseHandler(IBMQuantumExperienceError.invalidURL(url: ""))
            return RequestTask()
        }
        guard let baseURL = URL(string: baseURLPath) else {
            responseHandler(IBMQuantumExperienceError.invalidURL(url: baseURLPath))
            return RequestTask()
        }
        if let token = self.token_unique {
            let path = "users/loginWithToken"
            guard let url = URL(string: path, relativeTo: baseURL) else {
                DispatchQueue.main.async {
                    responseHandler(IBMQuantumExperienceError.invalidURL(url: "\(baseURLPath)/\(path)"))
                }
                return RequestTask()
            }
            return request.postInternal(url: url, data: ["apiToken": token]) { (out, error) -> Void in
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
        }
        else if let email = self.config["email"] as? String,
            let password = self.config["password"] as? String {
            let path = "users/login"
            guard let url = URL(string: path, relativeTo: baseURL) else {
                DispatchQueue.main.async {
                    responseHandler(IBMQuantumExperienceError.invalidURL(url: "\(baseURLPath)/\(path)"))
                }
                return RequestTask()
            }
            return request.postInternal(url: url, data: ["email": email, "password" : password]) { (out, error) -> Void in
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
        }
        else {
            DispatchQueue.main.async {
                responseHandler(IBMQuantumExperienceError.missingTokenId)
            }
            return RequestTask()
        }
    }
}
