//
//  Credentials.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

final class Credentials {

    let config: Qconfig
    private(set) var token: String?
    private(set) var ttl: Int?
    private(set) var created: String?
    private(set) var userId: String?

    init(config: Qconfig) {
        self.config = config
    }

    func obtainToken(request: Request, responseHandler: @escaping ((_:Error?) -> Void)) {
        let path = "users/loginWithToken"
        guard let url = URL(string: path, relativeTo: self.config.url) else {
            responseHandler(IBMQuantumExperienceError.invalidURL(url: "\(self.config.url.description)/\(path)"))
            return
        }
        request.postInternal(url: url,
                     data: ["apiToken": (self.config.apiToken as AnyObject)]) { (json, error) -> Void in
            self.token = nil
            if let token = json["id"] as? String {
                self.token = token
            }
            self.ttl = nil
            if let ttl = json["ttl"] as? NSNumber {
                self.ttl = ttl.intValue
            }
            self.created = nil
            if let created = json["created"] as? String {
                self.created = created
            }
            self.userId = nil
            if let userId = json["userId"] as? String {
                self.userId = userId
            }
            responseHandler(error)
        }
    }
}
