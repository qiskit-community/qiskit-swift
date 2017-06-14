//
//  Credentials.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class Credentials {

    private let token_unique: String
    let config: Qconfig
    private(set) var data_credentials: [String:AnyObject] = [:]

    var token: String? {
        return self.data_credentials["id"] as? String
    }
    var userId: String? {
        return self.data_credentials["userId"] as? String
    }

    init(_ token: String, _ config: Qconfig? = nil) throws {
        self.token_unique = token
        if let c = config {
            self.config = c
        }
        else {
            self.config = try Qconfig()
        }
    }

    func obtainToken(request: Request, responseHandler: @escaping ((_:IBMQuantumExperienceError?) -> Void)) {
        let path = "users/loginWithToken"
        guard let url = URL(string: path, relativeTo: self.config.url) else {
            responseHandler(IBMQuantumExperienceError.invalidURL(url: "\(self.config.url.description)/\(path)"))
            return
        }
        request.postInternal(url: url,
                     data: ["apiToken": (self.token_unique as AnyObject)]) { (json, error) -> Void in
            self.data_credentials = json
            responseHandler(error)
        }
    }
}
