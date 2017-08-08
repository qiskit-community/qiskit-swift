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

/**
 Built-in Single Qubit Gate class
 */
public final class UBase: Gate {

    fileprivate init(_ params: [Double], _ qubit: QuantumRegisterTuple, _ circuit: QuantumCircuit? = nil) throws {
        if params.count != 3 {
            throw QISKitException.not3params
        }
        super.init("U", params, [qubit], circuit)
    }

    public override var description: String {
        let theta = self.params[0].format(15)
        let phi = self.params[1].format(15)
        let lam = self.params[2].format(15)
        return self._qasmif("\(name)(\(theta),\(phi),\(lam)) \(self.args[0].identifier)")
    }

    /**
     Invert this gate.
     U(theta,phi,lambda)^dagger = U(-theta,-lambda,-phi)
     */
    public override func inverse() -> Gate {
        self.params[0] = -self.params[0]
        let phi = self.params[1]
        self.params[1] = -self.params[2]
        self.params[2] = -phi
        return self
    }

    /**
     Reapply this gate to corresponding qubits in circ.
     */
    public override func reapply(_ circ: QuantumCircuit) throws {
        try self._modifiers(circ.u_base(self.params, self.args[0] as! QuantumRegisterTuple))
    }
}

extension QuantumCircuit {

    /**
     Apply U to q
     */
    @discardableResult
    public func u_base(_ params: [Double], _ q: QuantumRegisterTuple) throws -> UBase {
        try self._check_qubit(q)
        return try self._attach(UBase(params, q, self)) as! UBase
    }
}

extension CompositeGate {

    /**
     Apply U to q
     */
    @discardableResult
    public func u_base(_ params: [Double], _ q: QuantumRegisterTuple) throws -> UBase {
        try self._check_qubit(q)
        return try self._attach(UBase(params, q, self.circuit)) as! UBase
    }
}
