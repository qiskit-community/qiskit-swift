//
//  Mapping.swift
//  qiskit
//
//  Created by Manoel Marques on 6/6/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Layout module to assist with mapping circuit qubits onto physical qubits.
 */
/**
 Notes:
 Measurements may occur and be followed by swaps that result in repeated
 measurement of the same qubit. Near-term experiments cannot implement
 these circuits, so we may need to modify the algorithm.
 It can happen that a swap in a deeper layer can be removed by permuting
 qubits in the layout. We don't do this.
 It can happen that initial swaps can be removed or partly simplified
 because the initial state is zero. We don't do this.
 */
final class Mapping {

    private init() {
    }

    /**
     Find a swap circuit that implements a permutation for this layer.
     The goal is to swap qubits such that qubits in the same two-qubit gates
     are adjacent.
     Based on Sergey Bravyi's algorithm.
     The layer_partition is a list of (qu)bit lists and each qubit is a
     tuple (qreg, index).
     The layout is a dict mapping qubits in the circuit to qubits in the
     coupling graph and represents the current positions of the data.
     The qubit_subset is the subset of qubits in the coupling graph that
     we have chosen to map into.
     The coupling is a CouplingGraph.
     TRIALS is the number of attempts the randomized algorithm makes.
     Returns: success_flag, best_circ, best_d, best_layout, trivial_flag
     If success_flag is True, then best_circ contains an OPENQASM string with
     the swap circuit, best_d contains the depth of the swap circuit, and
     best_layout contains the new positions of the data qubits after the
     swap circuit has been applied. The trivial_flag is set if the layer
     has no multi-qubit gates.
     */
    static func layer_permutation(layer_partition: [[RegBit]],
                                  layout: [RegBit:RegBit],
                                  qubit_subset: [RegBit],
                                  coupling: Coupling,
                                  trials: Int) throws -> (Bool, String?, Int?, [RegBit:RegBit]?, Bool) {
        var rev_layout: [RegBit:RegBit] = [:]
        for (a,b) in layout {
            rev_layout[b] = a
        }
        var gates: [(RegBit,RegBit)] = []
        for layer in layer_partition {
            if layer.count > 2 {
                throw MappingError.layouterror
            }
            if layer.count == 2 {
                gates.append((layer[0],layer[1]))
            }
        }

        // Can we already apply the gates?
        var dist: Int = 0
        for g in gates {
            guard let r1 = layout[g.0] else {
                continue
            }
            guard let r2 = layout[g.1] else {
                continue
            }
            dist += try coupling.distance(r1,r2)
        }
        if dist == gates.count {
            return (true, "", 0, layout, gates.isEmpty)
        }

        // Begin loop over trials of randomized algorithm
        let n = coupling.size()
        var best_d: Int = Int.max  // initialize best depth
        var best_circ: String? = nil  // initialize best swap circuit
        var best_layout: [RegBit:RegBit]? = nil  // initialize best final layout
        for _ in 1...trials {
            var trial_layout = layout
            var rev_trial_layout = rev_layout
            var trial_circ = ""  // circuit produced in this trial

            // Compute Sergey's randomized distance
            var xi:[RegBit:[RegBit:Double]] = [:]
            for i in coupling.get_qubits() {
                xi[i] = [:]
            }
            for i in coupling.get_qubits() {
                for j in coupling.get_qubits() {
                    let scale: Double = 1.0 + Random().normal(mean: 0.0, standardDeviation: 1.0 / Double(n))
                    xi[i]![j] = scale * pow(Double(try coupling.distance(i, j)),2)
                    xi[j]![i] = xi[i]![j]
                }
            }
            // Loop over depths d up to a max depth of 2n+1
            var d: Int = 1
            var circ = ""  // circuit for this swap slice
            while d < 2*n+1 {
                // Set of available qubits
                var qubit_set = Set<RegBit>(qubit_subset)
                // While there are still qubits available
                while !qubit_set.isEmpty {
                    // Compute the objective function
                    var min_cost: Double = 0
                    for g in gates {
                        guard let r1 = trial_layout[g.0] else {
                            continue
                        }
                        guard let r2 = trial_layout[g.1] else {
                            continue
                        }
                        min_cost += xi[r1]![r2]!
                    }
                    //min_cost = sum([xi[trial_layout[g[0]]][trial_layout[g[1]]] for g in gates])
                    // Try to decrease objective function
                    var progress_made = false
                    // Loop over edges of coupling graph
                    var opt_layout: [RegBit:RegBit] = [:]
                    var rev_opt_layout: [RegBit:RegBit] = [:]
                    var opt_edge: HashableTuple<RegBit,RegBit>? = nil
                    for e in coupling.get_edges() {
                        // Are the qubits available?
                        if qubit_set.contains(e.one) && qubit_set.contains(e.two) {
                            // Try this edge to reduce the cost
                            var new_layout = trial_layout
                            new_layout[rev_trial_layout[e.one]!] = e.two
                            new_layout[rev_trial_layout[e.two]!] = e.one
                            var rev_new_layout = rev_trial_layout
                            rev_new_layout[e.one] = rev_trial_layout[e.two]
                            rev_new_layout[e.two] = rev_trial_layout[e.one]
                            // Compute the objective function
                            var new_cost: Double = 0
                            for g in gates {
                                guard let r1 = trial_layout[g.0] else {
                                    continue
                                }
                                guard let r2 = trial_layout[g.1] else {
                                    continue
                                }
                                new_cost += xi[r1]![r2]!
                            }
                            //new_cost = sum([xi[new_layout[g[0]]][new_layout[g[1]]] for g in gates])
                            // Record progress if we succceed
                            if new_cost < min_cost {
                                progress_made = true
                                min_cost = new_cost
                                opt_layout = new_layout
                                rev_opt_layout = rev_new_layout
                                opt_edge = e
                            }
                        }
                    }

                    // Were there any good choices?
                    if progress_made {
                        guard let e = opt_edge else {
                            break
                        }
                        qubit_set.remove(e.one)
                        qubit_set.remove(e.two)
                        trial_layout = opt_layout
                        rev_trial_layout = rev_opt_layout
                        circ += "swap \(e.one.description),\(e.two.description); "
                    }
                    else {
                        break
                    }
                }
                // We have either run out of qubits or failed to improve
                // Compute the coupling graph distance
                var dist: Int = 0
                for g in gates {
                    guard let r1 = trial_layout[g.0] else {
                        continue
                    }
                    guard let r2 = trial_layout[g.1] else {
                        continue
                    }
                    dist += try coupling.distance(r1,r2)
                }
                //dist = sum([coupling.distance(trial_layout[g[0]],trial_layout[g[1]]) for g in gates])
                // If all gates can be applied now, we are finished
                // Otherwise we need to consider a deeper swap circuit
                if dist == gates.count {
                    trial_circ += circ
                    break
                }

                // Increment the depth
                d += 1
            }
            // Either we have succeeded at some depth d < dmax or failed
            var dist: Int = 0
            for g in gates {
                guard let r1 = trial_layout[g.0] else {
                    continue
                }
                guard let r2 = trial_layout[g.1] else {
                    continue
                }
                dist += try coupling.distance(r1,r2)
            }
            //dist = sum([coupling.distance(trial_layout[g[0]],trial_layout[g[1]]) for g in gates])
            if dist == gates.count {
                if d < best_d {
                    best_circ = trial_circ
                    best_layout = trial_layout
                }
                best_d = min(best_d, d)
            }
        }
        if best_circ == nil {
            return (false, nil, nil, nil, false)
        }
        return (true, best_circ, best_d, best_layout, false)
    }

    /**
     Change the direction of CNOT gates to conform to CouplingGraph.
     circuit_graph = input Circuit
     coupling_graph = corresponding CouplingGraph
     verbose = optional flag to print more information
     Adds "h" to the circuit basis.
     Returns a Circuit object containing a circuit equivalent to
     circuit_graph but with CNOT gate directions matching the edges
     of coupling_graph. Raises an exception if the circuit_graph
     does not conform to the coupling_graph.
     */
    static func direction_mapper(_ circuit_graph: Circuit, _ coupling_graph: Coupling, _ verbose: Bool = false) throws -> Circuit {
        guard let basis = circuit_graph.basis["cx"] else {
            return circuit_graph
        }
        if basis != (2, 0, 0) {
            throw MappingError.unexpectedsignature(a: basis.0, b: basis.1, c: basis.2)
        }
        let flipped_qasm = "OPENQASM 2.0;\n" +
            "gate cx c,t { CX c,t; }\n" +
            "gate u2(phi,lambda) q { U(pi/2,phi,lambda) q; }\n" +
            "gate h a { u2(0,pi) a; }\n" +
            "gate cx_flipped a,b { h a; h b; cx b, a; h a; h b; }\n" +
            "qreg q[2];\n" +
            "cx_flipped q[0],q[1];\n"

        let u = Unroller(Qasm(data: flipped_qasm).parse(),CircuitBackend(["cx", "h"]))
        u.execute()
        let flipped_cx_circuit = (u.backend! as! CircuitBackend).circuit
        let cx_node_list = try circuit_graph.get_named_nodes("cx")
        let cg_edges = coupling_graph.get_edges()
        for cx_node in cx_node_list {
            guard let data = cx_node.data as? CircuitVertexOpData else {
                continue
            }
            let cxedge = HashableTuple<RegBit,RegBit>(data.qargs[0], data.qargs[1])
            if cg_edges.contains(cxedge) {
                if verbose {
                    print("cx \(cxedge.one.description), \(cxedge.two.description) -- OK")
                }
                continue
            }
            if cg_edges.contains(HashableTuple<RegBit,RegBit>(cxedge.two, cxedge.one)) {
                try circuit_graph.substitute_circuit_one(cx_node,flipped_cx_circuit,wires: [RegBit("q", 0), RegBit("q", 1)])
                if verbose {
                    print("cx \(cxedge.one.description), \(cxedge.two.description) -FLIP")
                }
                continue
            }
            throw MappingError.errorcouplinggraph(cxedge: cxedge)
        }
        return circuit_graph
    }
}
