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

final class CompiledCircuit {
    var json: [String:Any]? = nil
    var qasm: String? = nil
    var dag: DAGCircuit? = nil
    var final_layout: OrderedDictionary<RegBit,RegBit>? = nil
}

final class OpenQuantumCompiler {

    /**
     Compile the circuit.
         This builds the internal "to execute" list which is list of quantum
         circuits to run on different backends.
         Args:
         qasm_circuit (str): qasm text to compile
         silent (bool): is an option to print out the compiling information
         or not
         basis_gates (str): a comma seperated string and are the base gates,
                             which by default are: u1,u2,u3,cx,id
         coupling_map (dict): A directed graph of coupling::
             {
             control(int):
             [
             target1(int),
             target2(int),
             , ...
             ],
             ...
             }
             eg. {0: [2], 1: [2], 3: [2]}
         initial_layout (dict): A mapping of qubit to qubit::
             {
             ("q", strart(int)): ("q", final(int)),
             ...
             }
             eg.
             {
             ("q", 0): ("q", 0),
             ("q", 1): ("q", 1),
             ("q", 2): ("q", 2),
             ("q", 3): ("q", 3)
             }
         format (str): The target format of the compilation:
             {'dag', 'json', 'qasm'}
     Returns:
         Compiled circuit
     */
    static func compile(_ qasm_circuit: String,
                        basis_gates: String = "u1,u2,u3,cx,id",
                        coupling_map: [Int:[Int]]? = nil,
                        initial_layout: OrderedDictionary<RegBit,RegBit>? = nil,
                        silent: Bool = true,
                        get_layout: Bool = false,
                        format: String = "dag") throws -> CompiledCircuit {

        var compiled_dag_circuit = try _unroller_code(qasm_circuit, basis_gates)
        var final_layout:OrderedDictionary<RegBit,RegBit>? = nil

        // if a coupling map is given compile to the map
        if coupling_map != nil {
            if !silent {
                print("pre-mapping properties: \(try compiled_dag_circuit.property_summary())")
            }
            // Insert swap gates
            let coupling = try Coupling(coupling_map)
            if !silent {
                print("initial layout: \(initial_layout ?? OrderedDictionary<RegBit,RegBit>())")
            }
            var layout:OrderedDictionary<RegBit,RegBit> = OrderedDictionary<RegBit,RegBit>()
            (compiled_dag_circuit, layout) = try Mapping.swap_mapper(compiled_dag_circuit, coupling, initial_layout, verbose: false, trials: 20)
            final_layout = layout
            if !silent {
                print("final layout: \(final_layout!)")
            }
            // Expand swaps
            compiled_dag_circuit = try _unroller_code(try compiled_dag_circuit.qasm())
            // Change cx directions
            compiled_dag_circuit = try Mapping.direction_mapper(compiled_dag_circuit,coupling)
            // Simplify cx gates
            try Mapping.cx_cancellation(compiled_dag_circuit)
            // Simplify single qubit gates
            compiled_dag_circuit = try Mapping.optimize_1q_gates(compiled_dag_circuit)
            if !silent {
                print("post-mapping properties: \(try compiled_dag_circuit.property_summary())")
            }
        }

        let compiled_circuit = CompiledCircuit()
        // choose output format
        if format == "dag" {
            compiled_circuit.dag = compiled_dag_circuit
        }
        else if format == "json" {
            compiled_circuit.json = try dag2json(compiled_dag_circuit)
        }
        else if format == "qasm" {
            compiled_circuit.qasm = try compiled_dag_circuit.qasm()
        }
        else {
            throw QisKitCompilerError.unknownFormat(name: format)
        }
        if get_layout {
            compiled_circuit.final_layout = final_layout
        }
        return compiled_circuit
    }

    /**
     Unroll the code.
         Circuit is the circuit to unroll using the DAG representation.
         This is an internal function.
         Args:
             qasm_circuit: a circuit representation as qasm text.
             basis_gates (str): a comma seperated string and are the base gates,
                 which by default are: u1,u2,u3,cx,id
         Return:
             dag_ciruit (dag object): a dag representation of the circuit
                 unrolled to basis gates
     */
    private static func _unroller_code(_ qasm_circuit: String, _ basis_gates: String? = nil) throws -> DAGCircuit {
        var basis = "u1,u2,u3,cx,id"  // QE target basis
        if let b = basis_gates {
            basis = b
        }
        let program_node_circuit = try Qasm(data: qasm_circuit).parse()
        let unrolled_circuit = Unroller(program_node_circuit,
                                        DAGBackend(basis.components(separatedBy:",")))
        let dag_circuit_unrolled = try unrolled_circuit.execute() as! DAGCircuit
        return dag_circuit_unrolled
    }

    /**
     Make a Json representation of the circuit.
         Takes a circuit dag and returns json circuit obj. This is an internal
         function.
     Args:
         dag_ciruit (dag object): a dag representation of the circuit.
         basis_gates (str): a comma seperated string and are the base gates,
         which by default are: u1,u2,u3,cx,id
     Returns:
         the json version of the dag
     */
    static func dag2json(_ dag_circuit: DAGCircuit, basis_gates: String = "u1,u2,u3,cx,id") throws -> [String:Any] {
        // TODO: Jay: I think this needs to become a method like .qasm() for the DAG.
        var circuit_string: String = ""
        do {
            circuit_string = try dag_circuit.qasm(qeflag: true)
        } catch {
            circuit_string = try dag_circuit.qasm()
        }
        let unroller = Unroller(try Qasm(data: circuit_string).parse(), JsonBackend(basis_gates.components(separatedBy:",")))
        return try unroller.execute() as! [String:Any]
    }
}
