//
//  GraphEdge.swift
//  qiskit
//
//  Created by Manoel Marques on 5/24/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class GraphEdge<EdgeDataType: NSCopying> {

    public var data: EdgeDataType? = nil
    public let source: Int
    public let neighbor: Int

    init(_ source: Int, _ neighbor: Int) {
        self.source = source
        self.neighbor = neighbor
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = GraphEdge<EdgeDataType>(self.source,self.neighbor)
        if self.data != nil {
            let d = self.data!.copy(with: zone) as! EdgeDataType
            copy.data = d
        }
        return copy
    }
}
