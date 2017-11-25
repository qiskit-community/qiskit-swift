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
 Methods to assist with compiling tasks.
 */
public final class Compiling {

    private init() {
    }

    /**
     Compute Euler angles for a single-qubit gate.

     Find angles (theta, phi, lambda) such that
     unitary_matrix = phase * Rz(phi) * Ry(theta) * Rz(lambda)

     Return (theta, phi, lambda, "U(theta,phi,lambda)"). The last
     element of the tuple is the OpenQASM gate name with parameter
     values substituted.
     */
    public static func  euler_angles_1q(_ unitary_matrix: Matrix<Complex>) throws -> (Double,Double,Double,String) {
        let small: Double = pow(1.0, -10.0)
        if unitary_matrix.shape != (2, 2) {
            throw MappingError.eulerAngles1q2_2
        }
        let phase: Complex = unitary_matrix.det().power(-1.0/2.0)
        let U = unitary_matrix.mult(phase)  // U in SU(2)
        // OpenQASM SU(2) parameterization:
        // U[0, 0] = exp(-i(phi+lambda)/2) * cos(theta/2)
        // U[0, 1] = -exp(-i(phi-lambda)/2) * sin(theta/2)
        // U[1, 0] = exp(i(phi-lambda)/2) * sin(theta/2)
        // U[1, 1] = exp(i(phi+lambda)/2) * cos(theta/2)
        // Find theta
        var theta: Double = 0
        if U[0, 0].abs() > small {
            theta = 2 * acos(U[0, 0].abs())
        }
        else {
            theta = 2 * asin(U[1, 0].abs())
        }
        // Find phi and lambda
        var phase11: Complex = 0.0
        var phase10: Complex = 0.0
        if abs(cos(theta/2.0)) > small {
            phase11 = U[1, 1] / cos(theta/2.0)
        }
        if abs(sin(theta/2.0)) > small {
            phase10 = U[1, 0] / sin(theta/2.0)
        }
        let phiplambda = 2.0 * atan2(phase11.imag, phase11.real)
        let phimlambda = 2.0 * atan2(phase10.imag, phase10.real)
        var phi = 0.0
        var lamb = 0.0
        if U[0, 0].abs() > small && U[1, 0].abs() > small {
            phi = (phiplambda + phimlambda) / 2.0
            lamb = (phiplambda - phimlambda) / 2.0
        }
        else {
            if U[0, 0].abs() < small {
                lamb = -phimlambda
            }
            else {
                lamb = phiplambda
            }
        }
        // Check the solution
        var c1 = Complex(imag:-1) * phi / 2.0
        var c2 = Complex(imag: 1) * phi / 2.0
        let Rzphi: Matrix<Complex> = [[c1.exp(), 0],[0, c2.exp()] ]
        let Rytheta: Matrix<Complex> = [[Complex(real:cos(theta/2.0)), Complex(real:-sin(theta/2.0))],
                                        [Complex(real:sin(theta/2.0)), Complex(real:cos(theta/2.0))]]
        c1 = Complex(imag:-1) * lamb / 2.0
        c2 = Complex(imag: 1) * lamb / 2.0
        let Rzlambda: Matrix<Complex> = [[c1.exp(), 0],[0, c2.exp()]]
        let V = Rzphi.dot(Rytheta.dot(Rzlambda))
        if V.subtract(U).norm() > small {
            throw MappingError.eulerAngles1qResult
        }
        return (theta, phi, lamb, "U(\(theta.format(15)),\(phi.format(15)),\(lamb.format(15)))")
    }

    /**
     Return the gate u1, u2, or u3 implementing U with the fewest pulses.

     U(theta, phi, lam) is the input gate.

     The returned gate implements U exactly, not up to a global phase.

     Return (gate_string, params, "OpenQASM string") where gate_string is one of
     "u1", "u2", "u3", "id" and params is a 3-tuple of parameter values. The
     OpenQASM string is the name of the gate with parameters substituted.
     */
    public static func simplify_U(_ theta: Double, _ phi: Double, _ lam: Double) -> (String, (Double,Double,Double), String) {
        let epsilon: Double = pow(1.0, -13.0)
        var name = "u3"
        var params = (theta, phi, lam)
        var qasm = "u3(\(params.0.format(15)),\(params.1.format(15)),\(params.2.format(15)))"
        // Y rotation is 0 mod 2*pi, so the gate is a u1
        if abs(params.0.truncatingRemainder(dividingBy: 2.0 * Double.pi)) < epsilon {
            name = "u1"
            params = (0.0, 0.0, params.1 + params.2 + params.0)
            qasm = "u1(\(params.2.format(15)))"
        }
        // Y rotation is pi/2 or -pi/2 mod 2*pi, so the gate is a u2
        if name == "u3" {
            // theta = pi/2 + 2*k*pi
            if abs((params.0 - Double.pi / 2).truncatingRemainder(dividingBy: 2.0 * Double.pi)) < epsilon {
                name = "u2"
                params = (Double.pi / 2, params.1, params.2 + (params.0 - Double.pi / 2))
                qasm = "u2(\(params.1.format(15)),\(params.2.format(15)))"
            }
            // theta = -pi/2 + 2*k*pi
            if abs((params.0 + Double.pi / 2).truncatingRemainder(dividingBy: 2.0 * Double.pi)) < epsilon {
                name = "u2"
                params = (Double.pi / 2, params.1 + Double.pi, params.2 - Double.pi + (params.0 + Double.pi / 2))
                qasm = "u2(\(params.1.format(15)),\(params.2.format(15)))"
            }
        }
        // u1 and lambda is 0 mod 4*pi so gate is nop
        if name == "u1" && abs(params.2.truncatingRemainder(dividingBy: 4.0 * Double.pi)) < epsilon {
            name = "id"
            params = (0.0, 0.0, 0.0)
            qasm = "id"
        }
        return (name, params, qasm)
    }

    /**
     Return numpy array for Rz(theta).

     Rz(theta) = diag(exp(-i*theta/2),exp(i*theta/2))
     */
    public static func rz_array(_ theta: Double) -> Matrix<Complex> {
        let c1 = Complex(imag:-1) * theta / 2.0
        let c2 = Complex(imag: 1) * theta / 2.0
        return [[c1.exp(), 0],[0, c2.exp()]]
    }

    /**
     Return numpy array for Ry(theta).

     Ry(theta) = [[cos(theta/2), -sin(theta/2)], [sin(theta/2),  cos(theta/2)]])
     */
    public static func ry_array(_ theta: Double) -> Matrix<Complex> {
        return  [[Complex(real:cos(theta/2.0)), Complex(real:-sin(theta/2.0))],
                 [Complex(real:sin(theta/2.0)), Complex(real:cos(theta/2.0))]]
    }

    /**
     Decompose a two-qubit gate over CNOT + SU(2) using the KAK decomposition.

     Based on MATLAB implementation by David Gosset.

     Computes a sequence of 10 single and two qubit gates, including 3 CNOTs,
     which multiply to U, including global phase. Uses Vatan and Williams
     optimal two-qubit circuit (quant-ph/0308006v3). The decomposition algorithm
     which achieves this is explained well in Drury and Love, 0806.4015.

     unitary_matrix = numpy 4x4 unitary matrix
     */
    public static func two_qubit_kak(_ unitary_matrix: Matrix<Complex>) throws -> [[String:Any]] {
        if unitary_matrix.shape != (4, 4) {
            throw MappingError.twoQubitKakMatrix4x4
        }
        let phase = unitary_matrix.det().power(-1.0/4.0)
        // Make it in SU(4), correct phase at the end
        let U = unitary_matrix.mult(phase)
        // B changes to the Bell basis
        var B: Matrix<Complex> = [[1, Complex(imag: 1),                0,  0],
                                  [0,                0, Complex(imag: 1),  1],
                                  [0,                0, Complex(imag: 1), -1],
                                  [1, Complex(imag:-1),                0,  0]]
        B = B.mult(1.0/2.0.squareRoot())
        // U' = Bdag . U . B
        let Uprime = Complex.conjugateMatrix(B).transpose().dot(U.dot(B))
        // M^2 = trans(U') . U'
        let M2 = Uprime.transpose().dot(Uprime)
        // Diagonalize M2
        // Must use diagonalization routine which finds a real orthogonal matrix P
        // when M2 is real.
        var (D, P) = M2.eig()
        // If det(P) == -1, apply a swap to make P in SO(4)
        if (P.det() + 1).abs() < pow(1.0, -5.0) {
            let swapM: Matrix<Complex> = [[1, 0, 0, 0],
                                          [0, 0, 1, 0],
                                          [0, 1, 0, 0],
                                          [0, 0, 0, 1]]
            P = P.dot(swapM)
            D = swapM.dot(D.diag().dot(swapM)).diag()
        }
        var Q = Complex.sqrtMatrix(D).diag()  // array from elementwise sqrt
        // Want to take square root so that Q has determinant 1
        if (Q.det() + 1).abs() < pow(1.0, -5.0) {
            Q[0, 0] = -1.0 * Q[0, 0]
        }
        let Kprime = Uprime.dot(P.dot(Q.inv().dot(P.transpose())))
        let K1 = B.dot(Kprime.dot(P.dot(Complex.conjugateMatrix(B).transpose())))
        let A = B.dot(Q.dot(Complex.conjugateMatrix(B).transpose()))
        let K2 = B.dot(P.transpose().dot(Complex.conjugateMatrix(B).transpose()))
        let KAK = K1.dot(A.dot(K2))
        if (KAK.subtract(U)).norm(2) > 1e-6 {
            throw MappingError.twoQubitKakDecomposition
        }
        // Compute parameters alpha, beta, gamma so that
        // A = exp(i * (alpha * XX + beta * YY + gamma * ZZ))
        let x: Matrix<Complex> = [[0,                1],
                                  [1,               0]]
        let y: Matrix<Complex> = [[0,               Complex(imag:-1)],
                                  [Complex(imag:1), 0]]
        let z: Matrix<Complex> = [[1,               0],
                                  [0,               Complex(imag:-1)]]
        let xx = x.kron(x)
        let yy = y.kron(y)
        let zz = z.kron(z)
        let alpha = atan( Complex.imagMatrix(A.dot(xx)).trace() / Complex.realMatrix(A).trace() )
        let beta  = atan( Complex.imagMatrix(A.dot(yy)).trace() / Complex.realMatrix(A).trace() )
        let gamma = atan( Complex.imagMatrix(A.dot(zz)).trace() / Complex.realMatrix(A).trace() )
        // K1 = kron(U1, U2) and K2 = kron(V1, V2)
        // Find the matrices U1, U2, V1, V2
        var L = K1.slice((0,2),(0,2))
        if L.norm() < pow(1.0, -9.0) {
            L = K1.slice((0,2), (2,4))
            if L.norm() < pow(1.0, -9.0) {
                L = K1.slice((2,4),(2,4))
            }
        }
        Q = (L.dot(Complex.conjugateMatrix(L).transpose()))
        let U2 = L.div(Q[0, 0].sqrt())
        var R = K1.dot(Matrix<Complex>.identity(2).kron(Complex.conjugateMatrix(U2).transpose()))
        var U1 : Matrix<Complex> = [[0, 0], [0, 0]]
        U1[0, 0] = R[0, 0]
        U1[0, 1] = R[0, 2]
        U1[1, 0] = R[2, 0]
        U1[1, 1] = R[2, 2]
        L = K2.slice((0,2),(0,2))
        if L.norm() < pow(1.0, -9.0) {
            L = K2.slice((0,2), (2,4))
            if L.norm() < pow(1.0, -9.0) {
                L = K2.slice((2,4), (2,4))
            }
        }
        Q = L.dot(Complex.conjugateMatrix(L).transpose())
        var V2 = L.div(Q[0, 0].sqrt())
        R = K2.dot(Matrix<Complex>.identity(2).kron(Complex.conjugateMatrix(V2).transpose()))
        var V1 : Matrix<Complex> = [[0, 0], [0, 0]]
        V1[0, 0] = R[0, 0]
        V1[0, 1] = R[0, 2]
        V1[1, 0] = R[2, 0]
        V1[1, 1] = R[2, 2]
        if U1.kron(U2).subtract(K1).norm() > pow(1.0, -4.0) ||
           V1.kron(V2).subtract(K2).norm() > pow(1.0, -4.0) {
            throw MappingError.twoQubitKakSU
        }
        let test = xx.mult(Complex(real:alpha)).add(yy.mult(Complex(real:beta))).add(zz.mult(Complex(real:gamma))).mult(Complex(imag:1)).expm()
        if A.subtract(test).norm() > pow(1.0, -4.0) {
            throw MappingError.twoQubitKakA
        }
        // Circuit that implements K1 * A * K2 (up to phase), using
        // Vatan and Williams Fig. 6 of quant-ph/0308006v3
        // Include prefix and suffix single-qubit gates into U2, V1 respectively.
        let m: Matrix<Complex> = [[(Complex(imag:1) * Double.pi/4.0).exp(), 0],
                                  [0, (Complex(imag:-1) * Double.pi/4.0).exp()]]
        V2 = m.dot(V2)
        U1 = U1.dot([[(Complex(imag:-1) * Double.pi/4.0).exp(), 0],
                     [0, (Complex(imag:1) * Double.pi/4.0).exp()]])
        // Corrects global phase: exp(ipi/4)*phase'
        U1 = U1.dot([[(Complex(imag:1) * Double.pi/4.0).exp(), 0],
                     [0, (Complex(imag:1) * Double.pi/4.0).exp()]])
        U1 = U1.mult(phase.conjugate())

        // Test
        let g1 = V1.kron(V2)
        let g2 : Matrix<Complex> = [[1, 0, 0, 0],
                                    [0, 0, 0, 1],
                                    [0, 0, 1, 0],
                                    [0, 1, 0, 0]]
        let theta = 2*gamma - Double.pi/2
        let Ztheta: Matrix<Complex> = [[(Complex(imag:1) * theta/2.0).exp(), 0],
                                       [0, (Complex(imag:-1) * theta/2.0).exp()]]
        let kappa = Double.pi/2 - 2*alpha
        let Ykappa: Matrix<Complex> = [[Complex(real: cos(kappa/2)), Complex(real:sin(kappa/2))],
                                       [Complex(real:-sin(kappa/2)), Complex(real:cos(kappa/2))]]
        let g3 = Ztheta.kron(Ykappa)
        let g4: Matrix<Complex> =   [[1, 0, 0, 0],
                                     [0, 1, 0, 0],
                                     [0, 0, 0, 1],
                                     [0, 0, 1, 0]]
        let zeta = 2*beta - Double.pi/2
        let Yzeta: Matrix<Complex> = [[Complex(real: cos(zeta/2)), Complex(real:sin(zeta/2))],
                                      [Complex(real:-sin(zeta/2)), Complex(real:cos(zeta/2))]]
        let g5 = Matrix<Complex>.identity(2).kron(Yzeta)
        let g6 = g2
        let g7 = U1.kron(U2)

        var V = g2.dot(g1)
        V = g3.dot(V)
        V = g4.dot(V)
        V = g5.dot(V)
        V = g6.dot(V)
        V = g7.dot(V)

        if V.subtract(U.mult(phase.conjugate())).norm() > pow(1.0, -6.0) {
            throw MappingError.twoQubitKakSequence
        }
        let v1_param = try euler_angles_1q(V1)
        let v2_param = try euler_angles_1q(V2)
        let u1_param = try euler_angles_1q(U1)
        let u2_param = try euler_angles_1q(U2)

        let v1_gate = simplify_U(v1_param.0, v1_param.1, v1_param.2)
        let v2_gate = simplify_U(v2_param.0, v2_param.1, v2_param.2)
        let u1_gate = simplify_U(u1_param.0, u1_param.1, u1_param.2)
        let u2_gate = simplify_U(u2_param.0, u2_param.1, u2_param.2)

        var return_circuit: [[String:Any]] = []
        return_circuit.append([
            "name": v1_gate.0,
            "args": [0],
            "params": [v1_gate.1.0,v1_gate.1.1,v1_gate.1.2]
        ])
        return_circuit.append([
            "name": v2_gate.0,
            "args": [1],
            "params": [v2_gate.1.0,v2_gate.1.1,v2_gate.1.2]
        ])
        return_circuit.append([
            "name": "cx",
            "args": [1, 0],
            "params": []
        ])

        var gate = simplify_U(0.0, 0.0, -2.0*gamma + Double.pi/2.0)
        return_circuit.append([
            "name": gate.0,
            "args": [0],
            "params": [gate.1.0,gate.1.1,gate.1.2]
        ])
        gate = simplify_U(-Double.pi/2.0 + 2.0*alpha, 0.0, 0.0)
        return_circuit.append([
            "name": gate.0,
            "args": [1],
            "params": [gate.1.0,gate.1.1,gate.1.2]
        ])
        return_circuit.append([
            "name": "cx",
            "args": [0, 1],
            "params": []
        ])
        gate = simplify_U(-2.0*beta + Double.pi/2.0, 0.0, 0.0)
        return_circuit.append([
            "name": gate.0,
            "args": [1],
            "params": [gate.1.0,gate.1.1,gate.1.2]
        ])
        return_circuit.append([
            "name": "cx",
            "args": [1, 0],
            "params": []
        ])
        return_circuit.append([
            "name": u1_gate.0,
            "args": [0],
            "params": [u1_gate.1.0,u1_gate.1.1,u1_gate.1.2]
        ])
        return_circuit.append([
            "name": u2_gate.0,
            "args": [1],
            "params": [u2_gate.1.0,u2_gate.1.1,u2_gate.1.2]
        ])

        // Test gate sequence
        V = Matrix<Complex>.identity(4)
        let cx21: Matrix<Complex> = [[1, 0, 0, 0],
                                     [0, 0, 0, 1],
                                     [0, 0, 1, 0],
                                     [0, 1, 0, 0]]
        let cx12: Matrix<Complex> = [[1, 0, 0, 0],
                                     [0, 1, 0, 0],
                                     [0, 0, 0, 1],
                                     [0, 0, 1, 0]]
        for gate in return_circuit {
            var name = ""
            if let n = gate["name"] as? String {
                name = n
            }
            var args: [Int] = []
            if let a = gate["args"] as? [Int] {
                args = a
            }
            var params: [Double] = [0,0,0]
            if let p = gate["params"] as? [Double] {
                params = p
            }
            if name == "cx" {
                if args == [0, 1] {
                    V = cx12.dot(V)
                }
                else {
                    V = cx21.dot(V)
                }
            }
            else {
                if args == [0] {
                    V = rz_array(params[2]).kron(Matrix<Complex>.identity(2)).dot(V)
                    V = ry_array(params[0]).kron(Matrix<Complex>.identity(2)).dot(V)
                    V = rz_array(params[1]).kron(Matrix<Complex>.identity(2)).dot(V)
                }
                else {
                    V = Matrix<Complex>.identity(2).kron(rz_array(params[2])).dot(V)
                    V = Matrix<Complex>.identity(2).kron(ry_array(params[0])).dot(V)
                    V = Matrix<Complex>.identity(2).kron(rz_array(params[1])).dot(V)
                }
            }
        }
        // Put V in SU(4) and test up to global phase
        V = V.mult(V.det().power((-1.0/4.0)))
        if V.subtract(U).norm()                         > pow(1.0, -6.0) &&
            V.mult(Complex(imag:1)).subtract(U).norm()  > pow(1.0, -6.0) &&
            V.mult(-1).subtract(U).norm()               > pow(1.0, -6.0) &&
            V.mult(Complex(imag:-1)).subtract(U).norm() > pow(1.0, -6.0) {
            throw MappingError.twoQubitKakSequence
        }
        return return_circuit
    }
}
