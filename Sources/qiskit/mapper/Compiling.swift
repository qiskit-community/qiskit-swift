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
final class Compiling {

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
        return (theta, phi, lamb, "U(\(theta.format(15)),\(phi.format(15)),\(lamb.format(15))")
    }
}
