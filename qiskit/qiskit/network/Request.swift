//
//  Request.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class Request {

    private static let HTTPSTATUSOK: Int = 200
    private static let REACHTIMEOUT: TimeInterval = 90.0
    private static let CONNTIMEOUT: TimeInterval = 120.0

    let credential: Credentials
    private var urlSession: URLSession
    private let verify: Bool
    private let retries: Int
    private let timeout_interval: Double

    init() throws {
        self.credential = try Credentials()

        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = Request.REACHTIMEOUT
        sessionConfig.timeoutIntervalForResource = Request.CONNTIMEOUT
        self.urlSession = URLSession(configuration: sessionConfig)
        self.verify = true
        self.retries = 5
        self.timeout_interval = 1.0
    }

    init(_ token: String,
         _ config: Qconfig? = nil,
         _ verify: Bool = true,
         _ retries: Int = 5,
         _ timeout_interval: TimeInterval = 1.0) throws {
        self.credential = try Credentials(token, config, verify)
        self.verify = verify
        self.retries = retries
        self.timeout_interval = timeout_interval
        if self.retries < 0 {
            throw IBMQuantumExperienceError.retriesPositive
        }
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = Request.REACHTIMEOUT
        sessionConfig.timeoutIntervalForResource = Request.CONNTIMEOUT
        self.urlSession = URLSession(configuration: sessionConfig)
    }

    private func check_token(_ error: IBMQuantumExperienceError?,
                             responseHandler: @escaping ((_:Bool, _:IBMQuantumExperienceError?) -> Void)) {
        if error != nil {
            if case IBMQuantumExperienceError.httpError(let status, _) = error! {
                if status == 401 {
                    self.credential.obtainToken(request: self) { (error) -> Void in
                        responseHandler(true,error)
                    }
                    return
                }
            }
        }
        responseHandler(false,error)
    }

    func post(path: String,
              params: String = "",
              data: [String : Any] = [:],
              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        self.postRetry(path: path, params: params, data: data, retries: self.retries, responseHandler: responseHandler)
    }

    private func postRetry(path: String,
              params: String,
              data: [String : Any],
              retries: Int,
              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        self.postWithCheckToken(path: path, params: params, data: data) { (json, error) in
            if error != nil {
                if retries > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout_interval) {
                        self.postRetry(path: path, params: params, data: data, retries: retries-1,responseHandler: responseHandler)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                responseHandler(json, error)
            }
        }
    }

    private func postWithCheckToken(path: String,
                                    params: String,
                                    data: [String : Any],
                                    responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        self.postInternal(path: path, params: params, data: data, verify: self.verify) { (json, error) in
            self.check_token(error) { (postAgain, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(nil, error)
                    }
                    return
                }
                if !postAgain {
                    DispatchQueue.main.async {
                        responseHandler(json, error)
                    }
                    return
                }
                self.postInternal(path: path, params: params, data: data, verify: self.verify) { (json, error) in
                    DispatchQueue.main.async {
                        responseHandler(json, error)
                    }
                }
            }
        }
    }

    private func postInternal(path: String,
                              params: String = "",
                              data: [String : Any] = [:],
                              verify: Bool,
                              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        guard let token = self.credential.token else {
            responseHandler(nil, IBMQuantumExperienceError.missingTokenId)
            return
        }
        let fullPath = "\(path)?access_token=\(token)\(params)"
        guard let url = URL(string: fullPath, relativeTo: self.credential.config.url) else {
            responseHandler(nil,
                    IBMQuantumExperienceError.invalidURL(url: "\(self.credential.config.url.description)\(fullPath)"))
            return
        }
        postInternal(url: url, data: data,verify: verify, responseHandler: responseHandler)
    }

    func postInternal(url: URL,
                      data: [String : Any] = [:],
                      verify: Bool,
                      responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        //print(url.absoluteString)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: Request.CONNTIMEOUT)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            //let dataString = String(data: request.httpBody!, encoding: .utf8)
            //print(dataString!)
        } catch let error {
            DispatchQueue.main.async {
                responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
            }
            return
        }
        let task = self.urlSession.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                DispatchQueue.main.async {
                    responseHandler(nil, IBMQuantumExperienceError.internalError(error: error!))
                }
                return
            }
            if response == nil {
                DispatchQueue.main.async {
                    responseHandler(nil, IBMQuantumExperienceError.nullResponse(url: url.absoluteString))
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    responseHandler(nil, IBMQuantumExperienceError.invalidHTTPResponse(response: response!))
                }
                return
            }
            if data == nil {
                DispatchQueue.main.async {
                    responseHandler(nil, IBMQuantumExperienceError.nullResponseData(url: url.absoluteString))
                }
                return
            }
            do {
                //if let dataString = String(data: data!, encoding: .utf8) {
                //   print(dataString)
                //}
                let jsonAny = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                var msg = ""
                if let json = jsonAny as? [String:Any] {
                    if let errorObj = json["error"] as? [String:Any] {
                        if let status = errorObj["status"] as? Int {
                            msg.append("Status: \(status)")
                        }
                        if let code = errorObj["code"] as? String {
                            msg.append("; Code: \(code)")
                        }
                        if let message = errorObj["message"] as? String {
                            msg.append("; Msg: \(message)")
                        }
                    }
                }
                if httpResponse.statusCode != Request.HTTPSTATUSOK {
                    DispatchQueue.main.async {
                        responseHandler(nil, IBMQuantumExperienceError.httpError(status: httpResponse.statusCode, msg: msg))
                    }
                    return
                }
                DispatchQueue.main.async {
                    responseHandler(jsonAny, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
                }
            }
        }
        task.resume()
    }

    func get(path: String, params: String = "", with_token: Bool = true,
             responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        self.getRetry(path: path, params: params, with_token: with_token, retries: self.retries, responseHandler: responseHandler)
    }

    private func getRetry(path: String,
                          params: String,
                          with_token: Bool,
                          retries: Int,
                          responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        self.getWithCheckToken(path: path, params: params, with_token: with_token) { (json, error) in
            if error != nil {
                if retries > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.timeout_interval) {
                        self.getRetry(path: path, params: params, with_token: with_token, retries: retries-1,responseHandler: responseHandler)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                responseHandler(json, error)
            }
        }
    }

    private func getWithCheckToken(path: String,
                                   params: String,
                                   with_token: Bool,
                                   responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        self.getInternal(path: path, params: params, with_token: with_token) { (json, error) in
            self.check_token(error) { (retry, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        responseHandler(nil, error)
                    }
                    return
                }
                if !retry {
                    DispatchQueue.main.async {
                        responseHandler(json, error)
                    }
                    return
                }
                self.getInternal(path: path, params: params, with_token: with_token) { (json, error) in
                    DispatchQueue.main.async {
                        responseHandler(json, error)
                    }
                }
            }
        }
    }

    private func getInternal(path: String,
                             params: String,
                             with_token: Bool,
                             responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) {
        var access_token = ""
        if with_token {
            if let token = self.credential.token {
                access_token = "?access_token=\(token)"
            }
            else {
                responseHandler(nil, IBMQuantumExperienceError.missingTokenId)
                return
            }
        }
        let fullPath = "\(path)\(access_token)\(params)"
        guard let url = URL(string: fullPath, relativeTo:self.credential.config.url) else {
            responseHandler(nil,
                IBMQuantumExperienceError.invalidURL(url: "\(self.credential.config.url.description)\(fullPath)"))
            return
        }
        //print(url.absoluteString)
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData,
                                 timeoutInterval:Request.CONNTIMEOUT)
        request.httpMethod = "GET"
        let task = self.urlSession.dataTask(with: request) { (data, response, error) -> Void in
            if error != nil {
                responseHandler(nil, IBMQuantumExperienceError.internalError(error: error!))
                return
            }
            if response == nil {
                responseHandler(nil, IBMQuantumExperienceError.nullResponse(url: url.absoluteString))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                responseHandler(nil, IBMQuantumExperienceError.invalidHTTPResponse(response: response!))
                return
            }
            if data == nil {
                responseHandler(nil, IBMQuantumExperienceError.nullResponseData(url: url.absoluteString))
                return
            }
            do {
               // if let dataString = String(data: data!, encoding: .utf8) {
                //    print(dataString)
                //}
                let jsonAny = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                var msg = ""
                if let json = jsonAny as? [String:Any] {
                    if let errorObj = json["error"] as? [String:Any] {
                        if let status = errorObj["status"] as? Int {
                            msg.append("Status: \(status)")
                        }
                        if let code = errorObj["code"] as? String {
                            msg.append("; Code: \(code)")
                        }
                        if let message = errorObj["message"] as? String {
                            msg.append("; Msg: \(message)")
                        }
                    }
                }
                if httpResponse.statusCode != Request.HTTPSTATUSOK {
                    responseHandler(nil, IBMQuantumExperienceError.httpError(status: httpResponse.statusCode, msg: msg))
                    return
                }
                responseHandler(jsonAny, nil)
            } catch let error {
                responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
            }
        }
        task.resume()
    }
}
