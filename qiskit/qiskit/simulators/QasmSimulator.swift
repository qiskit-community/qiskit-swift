//
//  QasmSimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
Contains a (slow) python simulator.

Author: Jay Gambetta and John Smolin

It simulates a qasm quantum circuit that has been compiled to run on the
simulator. It is exponential in the number of qubits.

We advise using the c++ simulator or online for larger size systems.

The input is
compiled_circuit object
shots
seed
and the output is the results object

if shots = 1
compiled_circuit['result']['data']['quantum_state'] and
results['data']['classical_state'] where quantum_state is
a 2**n complex numpy array representing the quantum state vector and
classical_state is a interger representing the state of the classical
registors.
if shots > 1
results['data']["counts"] where this is dict {"0000" : 454}

The simulator is run using

QasmSimulator(compiled_circuit,shots,seed).run().

compiled_circuit =
    {
        "header": {
            "number_of_qubits": 2, // int
            "number_of_clbits": 2, // int
            "qubit_labels": [["q", 0], ["v", 0]], // list[list[string, int]]
            "clbit_labels": [["c", 2]], // list[list[string, int]]
        }
        "operations": // list[map]
        [
        {
        "name": , // required -- string
        "params": , // optional -- list[double]
        "qubits": , // optional -- list[int]
        "clbits": , //optional -- list[int]
        "conditional":  // optional -- map
        {
        "type": , // string
        "mask": , // big int
        "val":  , // big int
        }
        },
        ]
}

if shots = 1
result =
{
    'data':
    {
        'quantum_state': array([ 1.+0.j,  0.+0.j,  0.+0.j,  0.+0.j]),
        'classical_state': 0
    }
    'status': 'DONE'
}

if shots > 1
result =
{
    'data':
    {
        'counts': {'0000': 50, '1001': 44},
    }
    'status': 'DONE'
}
 */

// TODO add the IF qasm operation.
// TODO add ["status"] = 'DONE', 'ERROR' especitally for empty circuit error
// does not show up

/**
 Implementation of a qasm simulator
 */
final class QasmSimulator: Simulator {

    static let __configuration: [String:Any] = [
        "name": "local_qasm_simulator",
        "url": "https://github.com/IBM/qiskit-sdk-py",
        "simulator": true,
        "description": "A python simulator for qasm files",
        "nQubits": 10,
        "couplingMap": "all-to-all",
        "gateset": "SU2+CNOT"
    ]

    /**
     Magic index1 function.

     Takes a bitstring k and inserts bit b as the ith bit,
     shifting bits >= i over to make room.
     */
    static private func _index1(_ b: Int, _ i: Int, _ k: Int) -> Int {
        var retval = k
        let lowbits: Int = k & ((1 << i) - 1)  // get the low i bits

        retval >>= i
        retval <<= 1

        retval |= b

        retval <<= i
        retval |= lowbits

        return retval
    }

    /**
     Magic index2 function.

     Takes a bitstring k and inserts bits b1 as the i1th bit
     and b2 as the i2th bit
     */
    static private func _index2(_ b1: Int, _ i1: Int, _ b2: Int, _ i2: Int, _ k: Int) -> Int {
        assert(i1 != i2)

        var retval: Int = 0
        if i1 > i2 {
            // insert as (i1-1)th bit, will be shifted left 1 by next line
            retval = QasmSimulator._index1(b1, i1-1, k)
            retval = QasmSimulator._index1(b2, i2, retval)
        }
        else { // i2>i1
            // insert as (i2-1)th bit, will be shifted left 1 by next line
            retval = QasmSimulator._index1(b2, i2-1, k)
            retval = QasmSimulator._index1(b1, i1, retval)
        }
        return retval
    }

    private(set) var circuit: [String:Any] = [:]
    private var _number_of_qubits: Int = 0
    private var _number_of_cbits: Int = 0
    private var result: [String:Any] = [:]
    private var _quantum_state: [Complex] = []
    private var _classical_state: Int = 0
    private var _shots: Int = 0
    private var _number_of_operations: Int = 0

    /**
     Initialize the QasmSimulator object
     */
    init(_ job: [String:Any]) throws {
        if let compiled_circuit = job["compiled_circuit"] as? String {
            if let data = compiled_circuit.data(using: .utf8) {
                let jsonAny = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let json = jsonAny as? [String:Any] {
                    self.circuit = json
                }
            }
        }
        if let header = self.circuit["header"]  as? [String:Any] {
            if let number_of_qubits = header["number_of_qubits"] as? Int {
                self._number_of_qubits = number_of_qubits
            }
            if let _number_of_cbits = header["number_of_clbits"] as? Int {
                self._number_of_cbits = _number_of_cbits
            }
        }
        self.result["data"] = [:]

        if let shots = job["shots"] as? Int {
            self._shots = shots
        }
        if let seed = job["seed"] as? Int {
            srand48(Int(seed))
        }
        if let operations = self.circuit["operations"]  as? [[String:Any]] {
            self._number_of_operations = operations.count
        }
    }

    /**
     Apply an arbitary 1-qubit operator to a qubit.

     Gate is the single qubit applied.
     qubit is the qubit the gate is applied to.
     */
    private func _add_qasm_single(_ gate: [[Complex]], _ qubit: Int) {
        var psi = self._quantum_state
        let bit = 1 << qubit
        for k1 in stride(from: 0, to: 1 << self._number_of_qubits, by: 1 << (qubit+1)) {
            for k2 in 0..<(1 << qubit) {
                let k = k1 | k2
                let cache0 = psi[k]
                let cache1 = psi[k | bit]
                psi[k] = gate[0][0] * cache0 + gate[0][1] * cache1
                psi[k | bit] = gate[1][0] * cache0 + gate[1][1] * cache1
            }
        }
        self._quantum_state = psi
    }

    /**
     Optimized ideal CX on two qubits.

     q0 is the first qubit (control) counts from 0.
     q1 is the second qubit (target).
     */
    private func _add_qasm_cx(_ q0: Int, _ q1: Int) {
        var psi = self._quantum_state
        for k in 0..<(1 << (self._number_of_qubits - 2)) {
            // first bit is control, second is target
            let ind1 = QasmSimulator._index2(1, q0, 0, q1, k)
            // swap target if control is 1
            let ind3 = QasmSimulator._index2(1, q0, 1, q1, k)
            let cache0 = psi[ind1]
            let cache1 = psi[ind3]
            psi[ind3] = cache0
            psi[ind1] = cache1
        }
        self._quantum_state = psi
    }

    /**
     Apply the decision of measurement/reset qubit gate.

     qubit is the qubit that is measured/reset
     */
    private func _add_qasm_decision(_ qubit: Int) -> (Int,Double) {
        var probability_zero: Double = 0
        let random_number = drand48()
        for ii in 0..<(1 << self._number_of_qubits) {
            if (ii & (1 << qubit)) == 0 {
                probability_zero += pow(self._quantum_state[ii].abs(),2)
            }
        }
        var outcome: Int = 0
        var norm: Double = 0
        if random_number <= probability_zero {
            outcome = 0
            norm = probability_zero.squareRoot()
        }
        else {
            outcome = 1
            norm = (1-probability_zero).squareRoot()
        }
        return (outcome, norm)
    }

    /**
     Apply the measurement qubit gate.

     qubit is the qubit measured.
     cbit is the classical bit the measurement is assigned to.
     */
    private func _add_qasm_measure(_ qubit: Int, _ cbit: Int) {
        let (outcome, norm) = self._add_qasm_decision(qubit)
        for ii in 0..<(1 << self._number_of_qubits) {
            // update quantum state
            if ((ii >> qubit) & 1) == outcome {
                self._quantum_state[ii] = self._quantum_state[ii]/norm
            }
            else {
                self._quantum_state[ii] = 0
            }
        }
        // update classical state
        let bit = 1 << cbit
        self._classical_state = (self._classical_state & (~bit)) | (outcome << cbit)
    }

    /**
     Apply the reset to the qubit.

     This is done by doing a measruement and if 0 do nothing and
     if 1 flip the qubit.

     qubit is the qubit that is reset.

     */
    private func _add_qasm_reset(_ qubit: Int) {
        // TODO: slow, refactor later
        let (outcome, norm) = self._add_qasm_decision(qubit)
        var temp = self._quantum_state
        self._quantum_state = [Complex](repeating: Complex(), count: _quantum_state.count)
        // measurement
        for ii in 0..<(1 << self._number_of_qubits) {
            if (ii >> qubit) & 1 == outcome {
                temp[ii] = temp[ii]/norm
            }
            else {
                temp[ii] = Complex()
            }
        }
        // reset
        if outcome == 1 {
            for ii in 0..<(1 << self._number_of_qubits) {
                let iip = (~(1 << qubit)) & ii  // bit number qubit set to zero
                self._quantum_state[iip] += temp[ii]
            }
        }
        else {
            self._quantum_state = temp
        }
    }

    /**
     Apply a single qubit gate to the qubit.

     Args:
     gate(str): the single qubit gate name
     params(list): the operation parameters op['params']
     Returns:
     a tuple of U gate parameters (theta, phi, lam)
     */
    private static func _qasm_single_params(_ gate: String, _ params: [Double]) -> (Double,Double,Double) {
        if gate == "U" || gate == "u3" {
            return (params[0], params[1], params[2])
        }
        else if gate == "u2" {
            return (Double.pi/2, params[0], params[1])
        }
        else if gate == "u1" {
            return (0.0, 0.0, params[0])
        }
        return (0.0,0.0,0.0)
    }

    func run() throws -> [String:Any] {
        var outcomes: [String] = []
        // Do each shot
        for _ in 0..<self._shots {
            self._quantum_state = [Complex](repeating: Complex(), count: 1 << self._number_of_qubits)
            self._quantum_state[0] = 1
            self._classical_state = 0
            if let operations = self.circuit["operations"] as? [[String:Any]] {
                // Do each operation in this shot
                for j in 0..<self._number_of_operations {
                    let operation = operations[j]
                    guard let name = operation["name"] as? String else {
                        self.result["status"] = "ERROR"
                        return self.result
                    }
                    // Check if single  gate
                    if ["U", "u1", "u2", "u3"].contains(name) {
                        if let qubits = operation["qubits"] as? [Int] {
                            if let params = operation["params"] as? [Double] {
                                let qubit = qubits[0]
                                let (theta, phi, lam) = QasmSimulator._qasm_single_params(name, params)
                                let gate: [[Complex]] = [[
                                             Complex(real:cos(theta/2.0)),
                                             Complex(imag: lam).exp() * -sin(theta/2.0)
                                            ],
                                            [
                                             Complex(imag: phi).exp() * sin(theta/2.0),
                                             (Complex(imag: phi) + Complex(imag: lam)).exp() * cos(theta/2.0)
                                            ]
                                ]
                                self._add_qasm_single(gate, qubit)
                            }
                        }
                    }
                    // Check if CX gate
                    else if name == "CX" || name == "cx" {
                        if let qubits = operation["qubits"] as? [Int] {
                            self._add_qasm_cx(qubits[0], qubits[1])
                        }
                    }
                    // Check if measure
                    else if name == "measure" {
                        if let qubits = operation["qubits"] as? [Int] {
                            if let clbits = operation["clbits"] as? [Int] {
                                self._add_qasm_measure(qubits[0], clbits[0])
                            }
                        }
                    }
                    // Check if reset
                    else if name == "reset" {
                        if let qubits = operation["qubits"] as? [Int] {
                            self._add_qasm_reset(qubits[0])
                        }
                    }
                    else if name == "barrier" || name == "id" {
                    }
                    else {
                        self.result["status"] = "ERROR"
                        return self.result
                    }
                }
            }
            // Turn classical_state (int) into bit string
            let binString = String(self._classical_state, radix: 2)
            let filledBin: String = String(repeating: "0", count: self._number_of_cbits - binString.characters.count) + binString
            outcomes.append(filledBin)
        }
        // Return the results
        var data: [String:Any] = [:]
        if self._shots == 1 {
            data["quantum_state"] = self._quantum_state
            data["classical_state"] = self._classical_state
        }
        else {
            var counter: [String:Int] = [:]
            for outcome in outcomes {
                if let count = counter[outcome] {
                    counter[outcome] = count + 1
                }
                else {
                    counter[outcome] = 1
                }
            }
            data["counts"] = counter
        }
        self.result["data"] = data
        self.result["status"] = "DONE"
        return self.result
    }
}
