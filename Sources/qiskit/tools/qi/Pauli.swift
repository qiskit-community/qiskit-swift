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
 "A simple class representing Pauli Operators.

 The form is P = (-i)^dot(v,w) Z^v X^w where v and w are elements of Z_2^n.
 That is, there are 4^n elements (no phases in this group).

 For example, for 1 qubit
 P_00 = Z^0 X^0 = I
 P_01 = X
 P_10 = Z
 P_11 = -iZX = (-i) iY = Y

 Multiplication is P1*P2 = (-i)^dot(v1+v2,w1+w2) Z^(v1+v2) X^(w1+w2)
 where the sums are taken modulo 2.

 Ref.
 Jeroen Dehaene and Bart De Moor
 Clifford group, stabilizer states, and linear and quadratic operations over GF(2)
 Phys. Rev. A 68, 042318 – Published 20 October 2003
 */
public final class Pauli: CustomStringConvertible {

    private var v: [Int] = []
    private var w: [Int] = []
    private let numberofqubits: Int

    /**
     Make the Pauli class.
    */
    public init(_ v: [Int], _ w: [Int]) {
        self.numberofqubits = v.count
        self.v = v
        self.w = w
    }

    /**
     Output the Pauli as first row v and second row w.
     */
    public var description: String {
        var stemp = "v = "
        for i in self.v {
            stemp += "\(i)\t"
        }
        stemp = stemp + "\nw = "
        for j in self.w {
            stemp += "\(j)\t"
        }
        return stemp
    }

    /**
     Multiply two Paulis.
     */
    static func * (left: Pauli, right: Pauli) throws -> Pauli {
        if left.numberofqubits != right.numberofqubits {
            throw ToolsError.invalidPauliMultiplication
        }
        var vnew = left.v
        vnew.append(contentsOf: right.v)
        vnew = vnew.map { $0 % 2 }
        var wnew = left.w
        wnew.append(contentsOf: right.w)
        wnew = wnew.map { $0 % 2 }
        return Pauli(vnew, wnew)
    }

    /**
     Print out the labels in X, Y, Z format.
     */
    public func to_label() -> String {
        var plabel = ""
        for jindex in 0..<self.numberofqubits {
            if self.v[jindex] == 0 && self.w[jindex] == 0 {
                plabel += "I"
            }
            else if self.v[jindex] == 0 && self.w[jindex] == 1 {
                plabel += "X"
            }
            else if self.v[jindex] == 1 && self.w[jindex] == 1 {
                plabel += "Y"
            }
            else if self.v[jindex] == 1 && self.w[jindex] == 0 {
                plabel += "Z"
            }
        }
        return plabel
    }

    /**
     Convert Pauli to a matrix representation.

     Order is q_n x q_{n-1} .... q_0
     */
    public func to_matrix() throws -> [[Complex]] {
        let X: [[Complex]] = [[0, 1], [1, 0]]
        let Z: [[Complex]] = [[1, 0], [0, -1]]
        let Id: [[Complex]] = [[1, 0], [0, 1]]
        var Xtemp: [[Complex]] = [[Complex(real: 1)]]
        for k in 0..<self.numberofqubits {
            var tempz: [[Complex]] = []
            if self.v[k] == 0 {
                tempz = Id
            }
            else if self.v[k] == 1 {
                tempz = Z
            }
            else {
                throw ToolsError.pauliToMatrixZ
            }
            var tempx: [[Complex]] = []
            if self.w[k] == 0 {
                tempx = Id
            }
            else if self.w[k] == 1 {
                tempx = X
            }
            else {
                throw ToolsError.pauliToMatrixX
            }
            let ope = NumUtilities.dotComplex(tempz, tempx)
            Xtemp = NumUtilities.kronComplex(ope, Xtemp)
        }
        return NumUtilities.multiplyScalarToMatrixComplex(Complex(imag: -1).power(NumUtilities.dotInt(self.v, self.w)) , Xtemp)
    }

    /**
     Return a random Pauli on numberofqubits.
     */
    public static func random_pauli(_ numberofqubits: UInt) -> Pauli {
        let random = Random(time(nil))
        return Pauli(Array(String(random.getrandbits(numberofqubits), radix:2).leftPadding(length: numberofqubits, pad: "0")).map { Int(String($0))! },
                     Array(String(random.getrandbits(numberofqubits), radix:2).leftPadding(length: numberofqubits, pad: "0")).map { Int(String($0))! })
    }
}
