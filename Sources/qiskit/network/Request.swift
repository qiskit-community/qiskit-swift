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

final class Request {

    private static let HTTPSTATUSOK: Int = 200
    private static let REACHTIMEOUT: TimeInterval = 90.0
    private static let CONNTIMEOUT: TimeInterval = 120.0
    private static let HEADER_CLIENT_APPLICATION = "x-qx-client-application"
    private static let _max_qubit_error_re = ".*registers exceed the number of qubits, it can't be greater than (\\d+).*"

    let credentials: Credentials
    private var urlSession: URLSession
    private let retries: UInt
    private let timeout_interval: Double

    init(_ credentials: Credentials,
         _ retries: UInt = 5,
         _ timeout_interval: TimeInterval = 1.0) throws {
        self.credentials = credentials
        self.retries = retries
        self.timeout_interval = timeout_interval
        #if os(Linux)
            let sessionConfig = URLSessionConfiguration.default
        #else
            let sessionConfig = URLSessionConfiguration.ephemeral
        #endif
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = Request.REACHTIMEOUT
        sessionConfig.timeoutIntervalForResource = Request.CONNTIMEOUT
        if !self.credentials.proxies.isEmpty {
            var dict = [AnyHashable : Any]()
            for proxy in self.credentials.proxies {
                guard let url = URL(string: proxy) else {
                    throw IBMQuantumExperienceError.invalidURL(url: proxy)
                }
                guard let scheme = url.scheme else {
                    throw IBMQuantumExperienceError.invalidURL(url: url.absoluteString)
                }
                guard let host = url.host else {
                    throw IBMQuantumExperienceError.invalidURL(url: url.absoluteString)
                }
                if scheme.lowercased() == "http" {
                    dict[kCFNetworkProxiesHTTPEnable] = true
                    dict[kCFNetworkProxiesHTTPProxy] = host
                    if let port = url.port {
                        dict[kCFNetworkProxiesHTTPPort] = port
                    }
                }
                else if scheme.lowercased() == "https" {
                    dict[kCFNetworkProxiesHTTPSEnable] = true
                    dict[kCFNetworkProxiesHTTPSProxy] = host
                    if let port = url.port {
                        dict[kCFNetworkProxiesHTTPSPort] = port
                    }
                }
                else {
                    throw IBMQuantumExperienceError.invalidURL(url: url.absoluteString)
                }
            }
            if !dict.isEmpty {
                sessionConfig.connectionProxyDictionary = dict
            }
        }
        self.urlSession = URLSession(configuration: sessionConfig)
    }

    func initialize(responseHandler: @escaping ((_:Request, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return self.credentials.initialize(self) { (error) -> Void in
            responseHandler(self,error)
        }
    }

    /**
     Check is the user's token is valid
     */
    private func check_token(_ error: IBMQuantumExperienceError?,
                             responseHandler: @escaping ((_:Bool, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        if error != nil {
            if case IBMQuantumExperienceError.httpError(let httpStatus, _, _, _) = error! {
                if httpStatus == 401 {
                    return self.credentials.obtain_token(self) { (error) -> Void in
                        responseHandler(true,error)
                    }
                }
            }
        }
        responseHandler(false,error)
        return RequestTask()
    }

    func post(path: String,
              params: String = "",
              data: [String : Any] = [:],
              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return self.postRetry(path: path, params: params, data: data, retries: self.retries, responseHandler: responseHandler)
    }

    private func postRetry(path: String,
              params: String,
              data: [String : Any],
              retries: UInt,
              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        let r = self.postWithCheckToken(path: path, params: params, data: data) { (json, error) in
            if error != nil {
                if retries > 0 {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.timeout_interval) {
                        let r = self.postRetry(path: path, params: params, data: data, retries: retries-1,responseHandler: responseHandler)
                        reqTask.add(r)
                    }
                    return
                }
            }
            responseHandler(json, error)
        }
        reqTask.add(r)
        return reqTask
    }

    private func postWithCheckToken(path: String,
                                    params: String,
                                    data: [String : Any],
                                    responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        let r = self.postInternal(path: path, params: params, data: data) { (json, error) in
            let r = self.check_token(error) { (postAgain, error) in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if !postAgain {
                    responseHandler(json, error)
                    return
                }
                let r = self.postInternal(path: path, params: params, data: data) { (json, error) in
                    responseHandler(json, error)
                }
                reqTask.add(r)
            }
            reqTask.add(r)
        }
        reqTask.add(r)
        return reqTask
    }

    private func postInternal(path: String,
                              params: String = "",
                              data: [String : Any] = [:],
                              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        guard let baseURLPath = self.credentials.config["url"] as? String else {
            responseHandler(nil, IBMQuantumExperienceError.invalidURL(url: ""))
            return RequestTask()
        }
        guard let baseURL = URL(string: baseURLPath) else {
            responseHandler(nil, IBMQuantumExperienceError.invalidURL(url: baseURLPath))
            return RequestTask()
        }
        guard let token = self.credentials.get_token() else {
            responseHandler(nil, IBMQuantumExperienceError.invalidToken)
            return RequestTask()
        }
        let fullPath = "\(path)\(Request.encodeURLQueryParams(token,params))"
        guard let url = URL(string: fullPath, relativeTo: baseURL) else {
            responseHandler(nil,IBMQuantumExperienceError.invalidURL(url: "\(baseURLPath)\(fullPath)"))
            return RequestTask()
        }
        return postInternal(url: url, data: data, responseHandler: responseHandler)
    }

    func postInternal(url: URL,
                      data: [String : Any] = [:],
                      responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: Request.CONNTIMEOUT)
        request.httpMethod = "POST"
        var client_application = Credentials.CLIENT_APPLICATION
        if let c = self.credentials.config["client_application"] as? String {
            client_application += ":" + c
        }
        request.addValue(client_application, forHTTPHeaderField: Request.HEADER_CLIENT_APPLICATION)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch let error {
            responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
            return RequestTask()
        }
        var reqTask = RequestTask()
        let task = self.urlSession.dataTask(with: request) { (data, response, error) -> Void in
            do {
                let out = try Request.response_good(reqTask, url, data, response, error)
                responseHandler(out, nil)
            } catch let error {
                if let e = error as? IBMQuantumExperienceError {
                    responseHandler(nil, e)
                }
                else {
                    responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
                }
            }
        }
        reqTask += RequestTask(task)
        task.resume()
        return reqTask
    }

    func put(path: String,
              params: String = "",
              data: [String : Any] = [:],
              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return self.putRetry(path: path, params: params, data: data, retries: self.retries, responseHandler: responseHandler)
    }

    private func putRetry(path: String,
                           params: String,
                           data: [String : Any],
                           retries: UInt,
                           responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        let r = self.putWithCheckToken(path: path, params: params, data: data) { (json, error) in
            if error != nil {
                if retries > 0 {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.timeout_interval) {
                        let r = self.putRetry(path: path, params: params, data: data, retries: retries-1,responseHandler: responseHandler)
                        reqTask.add(r)
                    }
                    return
                }
            }
            responseHandler(json, error)
        }
        reqTask.add(r)
        return reqTask
    }

    private func putWithCheckToken(path: String,
                                    params: String,
                                    data: [String : Any],
                                    responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        let r = self.putInternal(path: path, params: params, data: data) { (json, error) in
            let r = self.check_token(error) { (putAgain, error) in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if !putAgain {
                    responseHandler(json, error)
                    return
                }
                let r = self.putInternal(path: path, params: params, data: data) { (json, error) in
                    responseHandler(json, error)
                }
                reqTask.add(r)
            }
            reqTask.add(r)
        }
        reqTask.add(r)
        return reqTask
    }

    private func putInternal(path: String,
                              params: String = "",
                              data: [String : Any] = [:],
                              responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        guard let baseURLPath = self.credentials.config["url"] as? String else {
            responseHandler(nil, IBMQuantumExperienceError.invalidURL(url: ""))
            return RequestTask()
        }
        guard let baseURL = URL(string: baseURLPath) else {
            responseHandler(nil, IBMQuantumExperienceError.invalidURL(url: baseURLPath))
            return RequestTask()
        }
        guard let token = self.credentials.get_token() else {
            responseHandler(nil, IBMQuantumExperienceError.invalidToken)
            return RequestTask()
        }
        let fullPath = "\(path)\(Request.encodeURLQueryParams(token,params))"
        guard let url = URL(string: fullPath, relativeTo: baseURL) else {
            responseHandler(nil,IBMQuantumExperienceError.invalidURL(url: "\(baseURLPath)\(fullPath)"))
            return RequestTask()
        }
        return putInternal(url: url, data: data, responseHandler: responseHandler)
    }

    private func putInternal(url: URL,
                      data: [String : Any] = [:],
                      responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: Request.CONNTIMEOUT)
        request.httpMethod = "PUT"
        var client_application = Credentials.CLIENT_APPLICATION
        if let c = self.credentials.config["client_application"] as? String {
            client_application += ":" + c
        }
        request.addValue(client_application, forHTTPHeaderField: Request.HEADER_CLIENT_APPLICATION)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch let error {
            responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
            return RequestTask()
        }
        var reqTask = RequestTask()
        let task = self.urlSession.dataTask(with: request) { (data, response, error) -> Void in
            do {
                responseHandler(try Request.response_good(reqTask, url, data, response, error), nil)
            } catch let error {
                if let e = error as? IBMQuantumExperienceError {
                    responseHandler(nil, e)
                }
                else {
                    responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
                }
            }
        }
        reqTask += RequestTask(task)
        task.resume()
        return reqTask
    }

    func get(path: String, params: String = "", with_token: Bool = true,
             responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return self.getRetry(path: path, params: params, with_token: with_token, retries: self.retries, responseHandler: responseHandler)
    }

    private func getRetry(path: String,
                          params: String,
                          with_token: Bool,
                          retries: UInt,
                          responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        let r = self.getWithCheckToken(path: path, params: params, with_token: with_token) { (json, error) in
            if error != nil {
                if retries > 0 {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.timeout_interval) {
                        let r = self.getRetry(path: path, params: params, with_token: with_token, retries: retries-1,responseHandler: responseHandler)
                        reqTask.add(r)
                    }
                    return
                }
            }
            responseHandler(json, error)
        }
        reqTask.add(r)
        return reqTask
    }

    private func getWithCheckToken(path: String,
                                   params: String,
                                   with_token: Bool,
                                   responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        let reqTask = RequestTask()
        let r = self.getInternal(path: path, params: params, with_token: with_token) { (json, error) in
            let r = self.check_token(error) { (retry, error) in
                if error != nil {
                    responseHandler(nil, error)
                    return
                }
                if !retry {
                    responseHandler(json, error)
                    return
                }
                let r = self.getInternal(path: path, params: params, with_token: with_token) { (json, error) in
                    responseHandler(json, error)
                }
                reqTask.add(r)
            }
            reqTask.add(r)
        }
        reqTask.add(r)
        return reqTask
    }

    private func getInternal(path: String,
                             params: String,
                             with_token: Bool,
                             responseHandler: @escaping ((_:Any?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        guard let baseURLPath = self.credentials.config["url"] as? String else {
            responseHandler(nil, IBMQuantumExperienceError.invalidURL(url: ""))
            return RequestTask()
        }
        guard let baseURL = URL(string: baseURLPath) else {
            responseHandler(nil, IBMQuantumExperienceError.invalidURL(url: baseURLPath))
            return RequestTask()
        }
        var access_token = ""
        if with_token {
            if let token = self.credentials.get_token() {
                access_token = token
            }
            else {
                responseHandler(nil, IBMQuantumExperienceError.invalidToken)
                return RequestTask()
            }
        }
        let fullPath = "\(path)\(Request.encodeURLQueryParams(access_token,params))"
        guard let url = URL(string: fullPath, relativeTo:baseURL) else {
            responseHandler(nil,
                IBMQuantumExperienceError.invalidURL(url: "\(baseURLPath)\(fullPath)"))
            return RequestTask()
        }
        var request = URLRequest(url:url, cachePolicy:.reloadIgnoringLocalCacheData,
                                 timeoutInterval:Request.CONNTIMEOUT)
        request.httpMethod = "GET"
        var client_application = Credentials.CLIENT_APPLICATION
        if let c = self.credentials.config["client_application"] as? String {
            client_application += ":" + c
        }
        request.addValue(client_application, forHTTPHeaderField: Request.HEADER_CLIENT_APPLICATION)
        var reqTask = RequestTask()
        let task = self.urlSession.dataTask(with: request) { (data, response, error) -> Void in
            do {
                responseHandler(try Request.response_good(reqTask, url, data, response, error), nil)
            } catch let error {
                if let e = error as? IBMQuantumExperienceError {
                    responseHandler(nil, e)
                }
                else {
                    responseHandler(nil, IBMQuantumExperienceError.internalError(error: error))
                }
            }
        }
        reqTask += RequestTask(task)
        task.resume()
        return reqTask
    }

    static private func encodeURLQueryParams(_ token: String, _ params: String) -> String {
        var query = ""
        if !token.isEmpty {
            query += "access_token=\(token)"
        }
        if !params.isEmpty {
            if !query.isEmpty {
                if !params.hasPrefix("&") {
                    query += "&"
                }
                query += params
            }
            else {
                var p = params
                if p.hasPrefix("&") {
                    let index = p.index(p.startIndex, offsetBy:1)
                    p = String(p[...index])
                }
                query += p
            }
        }
        if !query.isEmpty {
            if let p = query.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) {
                query = p
            }
            query = "?" + query
        }
        return query
    }

    /**
     For Linux
     */
    private static func getNSError(_ error: Error) -> NSError {
        var code = -1
        let msg = error.localizedDescription
        if msg == "unsupported URL" {
            code = NSURLErrorUnsupportedURL
        }
        return NSError(domain: NSURLErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : msg])
    }

    static private func response_good(_ requestTask: RequestTask,
                                      _ url: URL,
                                      _ data: Data?,
                                      _ response: URLResponse?,
                                      _ error: Error?) throws -> Any {
        if error != nil {
            #if os(Linux)
                throw IBMQuantumExperienceError.internalError(error: getNSError(error!))
            #else
                if (error! as NSError).code == NSURLErrorCancelled {
                    throw IBMQuantumExperienceError.requestCancelled(error: error!)
                }
                else {
                    throw IBMQuantumExperienceError.internalError(error: error!)
                }
            #endif
        }
        if response == nil {
            throw IBMQuantumExperienceError.nullResponse(url: url.absoluteString)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw IBMQuantumExperienceError.invalidHTTPResponse(response: response!)
        }
        if data == nil {
            throw IBMQuantumExperienceError.nullResponseData(url: url.absoluteString)
        }
        var contentType: String = ""
        for (key,v) in httpResponse.allHeaderFields {
            if let name = key as? String, let value = v as? String {
                if name.lowercased() == "content-type" {
                    contentType = value.lowercased()
                    break
                }
            }
        }
        if contentType.hasPrefix("text/html") || contentType.hasPrefix("text/xml") {
            guard var value = String(data: data!, encoding: String.Encoding.utf8) else {
                throw IBMQuantumExperienceError.nullResponseData(url: url.absoluteString)
            }
            if value.isEmpty && httpResponse.url != nil {
                value = try String(contentsOf: httpResponse.url!, encoding: String.Encoding.utf8)
            }
            if value.contains("404 - Page Not Found") {
                throw IBMQuantumExperienceError.httpError(httpStatus: 404, status: 0,
                                                          code: "",
                                                          msg: HTTPURLResponse.localizedString(forStatusCode: 404))
            }
            let httpStatus = httpResponse.statusCode
            if httpStatus != Request.HTTPSTATUSOK {
                throw IBMQuantumExperienceError.httpError(httpStatus: httpStatus, status: 0, code: "", msg: value)
            }
            return value
        }
        var jsonAny: Any? = nil
        do {
            jsonAny = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        } catch let error {
            throw IBMQuantumExperienceError.internalError(error: error)
        }
        return try _parse_response(httpResponse.statusCode, jsonAny!)
    }

    private static func _parse_response(_ httpStatus: Int, _ jsonAny: Any) throws -> Any {
        var status: Int = 0
        var code: String = ""
        var message: String = ""
        var isResultError: Bool = false
        if let json = jsonAny as? [String:Any] {
            if let errorObj = json["error"] as? [String:Any] {
                isResultError = true
                if let s = errorObj["status"] as? Int {
                    status = s
                }
                if let c = errorObj["code"] as? String {
                    code = c
                }
                if let m = errorObj["message"] as? String {
                    message = m
                }
            }
        }
        // convert error messages into exceptions
        let wholeRange = message.startIndex..<message.endIndex
        if let match = message.range(of: _max_qubit_error_re, options: .regularExpression), wholeRange == match {
            throw IBMQuantumExperienceError.registerSizeError(msg: message)
        }
        if httpStatus != Request.HTTPSTATUSOK {
            throw IBMQuantumExperienceError.httpError(httpStatus: httpStatus, status: status, code: code, msg: message)
        }
        if isResultError {
            throw IBMQuantumExperienceError.resultError(status: status, code: code, msg: message)
        }
        return jsonAny
    }
}
