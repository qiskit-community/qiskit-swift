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
 These are tools that are used in the classical optimization and chemistry
 tutorials
 */
public final class Optimization {

    private init() {
    }

    /**
     Minimizes obj_fun(theta) with a simultaneous perturbation stochastic
     approximation algorithm.

     Args:
         obj_fun : the function to minimize
         initial_theta : initial value for the variables of obj_fun
         SPSA_parameters (list[float]) :  the parameters of the SPSA
            optimization routine
         max_trials (int) : the maximum number of trial steps ( = function
            calls/2) in the optimization
         save_steps (int) : stores optimization outcomes each 'save_steps'
            trial steps
         last_avg (int) : number of last updates of the variables to average
            on for the final obj_fun
     Returns:
         cost_final : final optimized value for obj_fun
         theta_best : final values of the variables corresponding to cost_final
         cost_plus_save : array of stored values for obj_fun along the
            optimization in the + direction
         cost_minus_save : array of stored values for obj_fun along the
            optimization in the - direction
         theta_plus_save : array of stored variables of obj_fun along the
            optimization in the + direction
         theta_minus_save : array of stored variables of obj_fun along the
            optimization in the - direction
     */
    public static func SPSA_optimization(_ obj_fun: ((_:[Double]) -> Double),
                                         _ initial_theta: [Double],
                                         _ SPSA_parameters: [Double],
                                         _ max_trials: Int,
                                         _ save_steps: Int = 1,
                                         _ last_avg: Int = 1) -> (Double,[Double],[Double],[Double],[[Double]],[[Double]]) {
        let random = Random(time(nil))
        var theta_plus_save: [[Double]] = []
        var theta_minus_save: [[Double]] = []
        var cost_plus_save: [Double] = []
        var cost_minus_save: [Double] = []
        var theta = Vector<Double>(value:initial_theta)
        var theta_best = Vector<Double>(repeating:0.0, count: initial_theta.count)
        for k in 0..<max_trials {
            // SPSA Paramaters
            let a_spsa = Double(SPSA_parameters[0]) / pow(Double(k + 1) + SPSA_parameters[4], SPSA_parameters[2])
            let c_spsa = Double(SPSA_parameters[1]) / pow(Double(k + 1), SPSA_parameters[3])
            var arr = Vector<Double>(repeating: 0, count: initial_theta.count)
            for i in 0..<arr.count {
                arr[i] = Double(random.randint(0, 2))
            }
            let delta = arr.mult(2).subtract(1)
            // plus and minus directions
            let theta_plus = theta.add(delta.mult(c_spsa))
            let theta_minus = theta.subtract(delta.mult(c_spsa))
            // cost fuction for the two directions
            let cost_plus = obj_fun(theta_plus.value)
            let cost_minus = obj_fun(theta_minus.value)
            // derivative estimate
            let g_spsa = delta.mult(cost_plus - cost_minus).div(2.0 * c_spsa)
            // updated theta
            theta = theta.subtract(g_spsa.mult(a_spsa))
            // saving
            if k % save_steps == 0 {
                print("objective function at theta+ for step # \(k)")
                print("\(cost_plus)")
                print("objective function at theta- for step # \(k)")
                print("\(cost_minus)")
                theta_plus_save.append(theta_plus.value)
                theta_minus_save.append(theta_minus.value)
                cost_plus_save.append(cost_plus)
                cost_minus_save.append(cost_minus)
            }
            if k >= max_trials - last_avg {
                theta_best = theta_best.add(theta.div(Double(last_avg)))
            }
        }
        // final cost update
        let cost_final = obj_fun(theta_best.value)
        print("Final objective function is: \(cost_final)")
        return (cost_final, theta_best.value, cost_plus_save, cost_minus_save,
                theta_plus_save, theta_minus_save)
    }

    /**
     Calibrates and returns the SPSA parameters.

     Args:
        obj_fun : the function to minimize.
        initial_theta : initial value for the variables of obj_fun.
        initial_c (float) : first perturbation of intitial_theta.
        target_update (float) : the aimed update of variables on the first
            trial step.
        stat (int) : number of random gradient directions to average on in
            the calibration.
     Returns:
        An array of 5 SPSA_parameters to use in the optimization.
     */
    public static func SPSA_calibration(_ obj_fun: ((_:[Double]) -> Double),
                                        _ initial_theta: [Double],
                                        _ initial_c: Double,
                                        _ target_update: Double,
                                        _ stat: Int) -> [Double] {
        let random = Random(time(nil))
        var SPSA_parameters = Array<Double>(repeating:0.0, count: 5)
        SPSA_parameters[1] = initial_c
        SPSA_parameters[2] = 0.602
        SPSA_parameters[3] = 0.101
        SPSA_parameters[4] = 0
        let theta = Vector<Double>(value:initial_theta)
        var delta_obj: Double = 0
        for i in 0..<stat {
            if i % 5 == 0 {
                print("calibration step # \(i) of \(stat)")
            }
            var arr = Vector<Double>(repeating: 0, count: initial_theta.count)
            for i in 0..<arr.count {
                arr[i] = Double(random.randint(0, 2))
            }
            let delta = arr.mult(2).subtract(1)
            let obj_plus = obj_fun(theta.add(delta.mult(initial_c)).value)
            let obj_minus = obj_fun(theta.subtract(delta.mult(initial_c)).value)
            delta_obj += abs(obj_plus - obj_minus) / Double(stat)
        }
        SPSA_parameters[0] = target_update * 2 / delta_obj * SPSA_parameters[1] * (SPSA_parameters[4] + 1)

        print("calibrated SPSA_parameters[0] is \(SPSA_parameters[0])")

        return SPSA_parameters
    }

    /**
     Compute the expectation value of Z.

     Z is represented by Z^v where v has lenght number of qubits and is 1
     if Z is present and 0 otherwise.

     Args:
        data : a dictionary of the form data = {'00000': 10}
        pauli : a Pauli object
     Returns:
        Expected value of pauli given data
     */
    public static func measure_pauli_z(_ data: [String: Int], _ pauli: Pauli) -> Int {
        var observable: Int = 0
        let tot = data.values.reduce(0, +)
        for (key,dataValue) in data {
            var value = 1
            let keyChars = Array(key)
            for j in 0..<pauli.numberofqubits {
                if ((pauli.v[j] == 1 || pauli.w[j] == 1) && keyChars[pauli.numberofqubits - j - 1] == "1") {
                    value = -value
                }
            }
            observable = observable + value * dataValue / tot
        }
        return observable
    }

    /**
     Compute expectation value of a list of diagonal Paulis with
     coefficients given measurement data. If somePaulis are non-diagonal
     appropriate post-rotations had to be performed in the collection of data

     Args:
        data : output of the execution of a quantum program
        pauli_list : list of [coeff, Pauli]
     Returns:
        The expectation value
     */
    public static func Energy_Estimate(_ data: [String: Int], _ pauli_list: [(Int,Pauli)]) -> Int {
        var energy: Int = 0
        for p in pauli_list {
            energy += p.0 * measure_pauli_z(data, p.1)
        }
        return energy
    }

    /**
     Returns bit string corresponding to quantum state index

     Args:
        state_index : basis index of a quantum state
        num_bits : the number of bits in the returned string
     Returns:
        A integer array with the binary representation of state_index
     */
    public static func index_2_bit(_ state_index: Int, _ num_bits: Int) -> [Int] {
        var binaryString = String(state_index, radix: 2)
        binaryString = String(repeating: "0", count: num_bits - binaryString.count) + binaryString
        var ret: [Int] = []
        for v in Array(binaryString) {
            ret.append(v == "1" ? 1 : 0)
        }
        return ret
    }
}
