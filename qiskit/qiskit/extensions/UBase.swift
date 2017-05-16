//
//  UBase.swift
//  qisswiftkit
//
//  Created by Manoel Marques on 4/28/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Cocoa

/**
 Built-in Single Qubit Gate class
 */
public final class UBase: Gate {

    public init(_ params: [Double], _ qreg: QuantumRegister) throws {
        if params.count != 3 {
            throw QISKitException.not3params
        }
        super.init("U", params, [qreg])
    }

    public init(_ params: [Double], _ qubit: QuantumRegisterTuple) throws {
        if params.count != 3 {
            throw QISKitException.not3params
        }
        super.init("U", params, [qubit])
    }

    public override var description: String {
        let theta = String(format:"%.15f",self.params[0])
        let phi = String(format:"%.15f",self.params[1])
        let lamb = String(format:"%.15f",self.params[2])
        return self._qasmif("\(name)(\(theta),\(phi),\(lamb)) \(self.args[0].identifier)")
    }
}
