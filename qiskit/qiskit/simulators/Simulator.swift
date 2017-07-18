//
//  Simulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

protocol Simulator {

    static var __configuration : [String:Any] {get}

    func run() throws -> [String:Any]
}
