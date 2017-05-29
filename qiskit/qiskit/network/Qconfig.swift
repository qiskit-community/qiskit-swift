//
//  Qconfig.swift
//  qiskit
//
//  Created by Manoel Marques on 4/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Quantum Experience Configuration
 */
public final class Qconfig {

    private static let BASEURL: String = "https://quantumexperience.ng.bluemix.net/api/"

    /// Target URL
    public var url: URL
    /// User API Token
    public var apiToken: String

    public init(apiToken: String = "", url: String = BASEURL) throws {
        self.apiToken = apiToken
        guard let u = URL(string: url) else {
            throw IBMQuantumExperienceError.invalidURL(url: url)
        }
        self.url = u
    }
}
