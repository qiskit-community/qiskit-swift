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
}
