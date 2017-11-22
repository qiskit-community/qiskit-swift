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
public final class Pauli: CustomStringConvertible, Hashable {

    public private(set) var v: Vector<Int> = []
    public private(set) var w: Vector<Int> = []
    public let numberofqubits: Int

    /**
     Make the Pauli class.
    */
    public convenience init(_ v: [Int], _ w: [Int]) {
        self.init(Vector<Int>(value:v),Vector<Int>(value:w))
    }

    public init(_ v: Vector<Int>, _ w: Vector<Int>) {
        self.numberofqubits = v.count
        self.v = v
        self.w = w
    }

    public func copy() -> Pauli {
        return Pauli(self.v,self.w)
    }

    public var hashValue : Int {
        return self.v.hashValue &* 31 &+ self.w.hashValue
    }
    public static func ==(lhs: Pauli, rhs:Pauli) -> Bool {
        return lhs.v == rhs.v && lhs.w == rhs.w
    }

    public func getV(_ index: Int) -> Int {
        return self.v[index]
    }

    public func setV(_ index: Int, _ value: Int) {
        self.v[index] = value
    }

    public func getW(_ index: Int) -> Int {
        return self.w[index]
    }

    public func setW(_ index: Int, _ value: Int) {
        self.w[index] = value
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
        let vnew = left.v.add(right.v).remainder(2)
        let wnew = left.w.add(right.w).remainder(2)
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
    public func to_matrix() throws -> Matrix<Complex> {
        let X: Matrix<Complex> = [[0, 1], [1, 0]]
        let Z: Matrix<Complex> = [[1, 0], [0, -1]]
        let Id: Matrix<Complex> = [[1, 0], [0, 1]]
        var Xtemp: Matrix<Complex> = [[1]]
        for k in 0..<self.numberofqubits {
            var tempz: Matrix<Complex> = []
            if self.v[k] == 0 {
                tempz = Id
            }
            else if self.v[k] == 1 {
                tempz = Z
            }
            else {
                throw ToolsError.pauliToMatrixZ
            }
            var tempx: Matrix<Complex> = []
            if self.w[k] == 0 {
                tempx = Id
            }
            else if self.w[k] == 1 {
                tempx = X
            }
            else {
                throw ToolsError.pauliToMatrixX
            }
            let ope = tempz.dot(tempx)
            Xtemp = ope.kron(Xtemp)
        }
        return Xtemp.mult(Complex(imag: -1).power(self.v.dot(self.w)))
    }

    /**
     Return a random Pauli on numberofqubits.
     */
    public static func random_pauli(_ numberofqubits: UInt) -> Pauli {
        let random = Random(time(nil))
        return Pauli(Array(String(random.getrandbits(numberofqubits), radix:2).leftPadding(length: numberofqubits, pad: "0")).map { Int(String($0))! },
                     Array(String(random.getrandbits(numberofqubits), radix:2).leftPadding(length: numberofqubits, pad: "0")).map { Int(String($0))! })
    }

    /**
     Multiply two Paulis P1*P2 and track the sign.

     P3 = P1*P2: X*Y
     */
    public static func sgn_prod(P1: Pauli, P2: Pauli) throws -> (Pauli,Complex) {
        if P1.numberofqubits != P2.numberofqubits {
            throw ToolsError.invalidPauliMultiplication
        }
        let vnew = P1.v.add(P2.v).remainder(2)
        let wnew = P1.w.add(P2.w).remainder(2)
        let paulinew = Pauli(vnew, wnew)
        var phase = Complex(real: 1)
        for i in 0..<P1.v.count {
            if P1.v[i] == 1 && P1.w[i] == 0 && P2.v[i] == 0 && P2.w[i] == 1 {  // Z*X
                phase = Complex(imag: 1) * phase
            }
            else if P1.v[i] == 0 && P1.w[i] == 1 && P2.v[i] == 1 && P2.w[i] == 0 {  // X*Z
                phase = Complex(imag: -1) * phase
            }
            else if P1.v[i] == 0 && P1.w[i] == 1 && P2.v[i] == 1 && P2.w[i] == 1 { // X*Y
                phase = Complex(imag: 1) * phase
            }
            else if P1.v[i] == 1 && P1.w[i] == 1 && P2.v[i] ==  0 && P2.w[i] == 1 {  // Y*X
                phase = Complex(imag: -1) * phase
            }
            else if P1.v[i] == 1 && P1.w[i] == 1 && P2.v[i] == 1 && P2.w[i] == 0 {  // Y*Z
                phase = Complex(imag: 1) * phase
            }
            else if P1.v[i] == 1 && P1.w[i] == 0 && P2.v[i] == 1 && P2.w[i] == 1 { // Z*Y
                phase = Complex(imag: -1) * phase
            }
        }
        return (paulinew, phase)
    }

    /**
     Return the inverse of a Pauli.
     */
    public static func inverse_pauli(other: Pauli) -> Pauli {
        return Pauli(other.v, other.w)
    }

    /**
     Return the pauli of a string .
     */
    public static func label_to_pauli(label: String) throws -> Pauli {
        var v = Vector<Int>(repeating: 0,count: label.count)
        var w = Vector<Int>(repeating: 0,count: label.count)
        let characters = Array(label)
        for j in 0..<characters.count {
            if characters[j] == "I" {
                v[j] = 0
                w[j] = 0
            }
            else if characters[j] == "Z" {
                v[j] = 1
                w[j] = 0
            }
            else if characters[j] == "Y" {
                v[j] = 1
                w[j] = 1
            }
            else if characters[j] == "X" {
                v[j] = 0
                w[j] = 1
            }
            else {
                throw ToolsError.invalidPauliString(label: label)
            }
        }
        return Pauli(v, w)
    }

    /**
     Return the Pauli group with 4^n elements.

     The phases have been removed.
     groupCase 0 is ordered by Pauli weights and
     groupCase 1 is ordered by I,X,Y,Z counting last qubit fastest.
     @param numberofqubits is number of qubits
     @param case determines ordering of group elements (0=weight, 1=tensor)
     @return list of Pauli objects
     WARNING THIS IS EXPONENTIAL
     */
    public static func pauli_group(_ numberofqubits: Int, groupCase: UInt = 0) throws -> [Pauli] {
        if numberofqubits < 5 {
            var tempset: [Pauli] = []
            if groupCase == 0 {
                let tmp = try Pauli.pauli_group(numberofqubits, groupCase: 1)
                // sort on the weight of the Pauli operator
                return tmp.sorted(by: { p1, p2 in
                    let p1Array = Array(p1.to_label())
                    var p1Count = 0
                    for x in p1Array {
                        if x == "I" {
                            p1Count += 1
                        }
                    }
                    let p2Array = Array(p2.to_label())
                    var p2Count = 0
                    for x in p2Array {
                        if x == "I" {
                            p2Count += 1
                        }
                    }
                    return (p1Count > p2Count)
                })
            }
            else if groupCase == 1 {
                // the Pauli set is in tensor order II IX IY IZ XI ...
                for kindex in 0..<Int(pow(4.0,Double(numberofqubits))) {
                    var v = Vector<Int>(repeating: 0, count: numberofqubits)
                    var w = Vector<Int>(repeating: 0, count: numberofqubits)
                    // looping over all the qubits
                    for jindex in 0..<numberofqubits {
                        // making the Pauli for each kindex i fill it in from the
                        // end first
                        let element = Int(kindex / Int(pow(4.0,Double(jindex)))) % 4
                        if element == 0 {
                            v[jindex] = 0
                            w[jindex] = 0
                        }
                        else if element == 1 {
                            v[jindex] = 0
                            w[jindex] = 1
                        }
                        else if element == 2 {
                            v[jindex] = 1
                            w[jindex] = 1
                        }
                        else if element == 3 {
                            v[jindex] = 1
                            w[jindex] = 0
                        }
                    }
                    tempset.append(Pauli(v, w))
                }
            }
            return tempset
        }
        else {
            throw ToolsError.errorPauliGroup
        }
    }

    /**
     Return the single qubit pauli in numberofqubits.
     */
    static public func pauli_singles(_ jindex: Int, _ numberofqubits: Int) -> [Pauli] {
        // looping over all the qubits
        var tempset: [Pauli] = []
        var v = Vector<Int>(repeating: 0, count: numberofqubits)
        var w = Vector<Int>(repeating: 0, count: numberofqubits)
        v[jindex] = 0
        w[jindex] = 1
        tempset.append(Pauli(v, w))
        v = Vector<Int>(repeating: 0, count: numberofqubits)
        w = Vector<Int>(repeating: 0, count: numberofqubits)
        v[jindex] = 1
        w[jindex] = 1
        tempset.append(Pauli(v, w))
        v = Vector<Int>(repeating: 0, count: numberofqubits)
        w = Vector<Int>(repeating: 0, count: numberofqubits)
        v[jindex] = 1
        w[jindex] = 0
        tempset.append(Pauli(v, w))
        return tempset
    }
}
