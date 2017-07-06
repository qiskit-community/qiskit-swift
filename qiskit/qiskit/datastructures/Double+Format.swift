//
//  Double+Format.swift
//  qiskit
//
//  Created by Manoel Marques on 7/5/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

extension Double {
    func format(_ f: Int) -> String {
        if self == 0.0 {
            return "0.0"
        }
        if self < 1.0 {
            return String(format: "%.\(f+1)f", self)
        }
        return String(format: "%.\(f)f", self)
    }
}
