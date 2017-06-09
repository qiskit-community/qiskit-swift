//
//  GraphError.swift
//  qiskit
//
//  Created by Manoel Marques on 6/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Graph Exceptions
 */
public enum GraphError: Error, CustomStringConvertible {

    case isUndirected
    case isCyclic
    case connectEmptyGraph

    public var description: String {
        switch self {
        case .isUndirected():
            return "Graph is undirected"
        case .isCyclic():
            return "Graph has cycles"
        case .connectEmptyGraph():
            return "Connectivity is undefined for the null graph."
        }
    }
}

