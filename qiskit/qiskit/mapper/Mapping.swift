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
    static func layer_permutation(_ layer_partition: [[RegBit]],
                                  _ layout: [RegBit:RegBit],
                                  _ qubit_subset: [RegBit],
                                  _ coupling: Coupling,
                                  _ trials: Int) throws -> (Bool, String?, Int?, [RegBit:RegBit]?, Bool) {
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
                    var opt_edge: TupleRegBit? = nil
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
            let cxedge = TupleRegBit(data.qargs[0], data.qargs[1])
            if cg_edges.contains(cxedge) {
                if verbose {
                    print("cx \(cxedge.one.description), \(cxedge.two.description) -- OK")
                }
                continue
            }
            if cg_edges.contains(TupleRegBit(cxedge.two, cxedge.one)) {
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

    /**
     Map a Circuit onto a CouplingGraph using swap gates.
     circuit_graph = input Circuit
     coupling_graph = CouplingGraph to map onto
     initial_layout = dict from qubits of circuit_graph to qubits
     of coupling_graph (optional)
     basis = basis string specifying basis of output Circuit
     verbose = optional flag to print more information
     Returns a Circuit object containing a circuit equivalent to
     circuit_graph that respects couplings in coupling_graph, and
     a layout dict mapping qubits of circuit_graph into qubits
     of coupling_graph. The layout may differ from the initial_layout
     if the first layer of gates cannot be executed on the
     initial_layout.
     */
    static func swap_mapper(_ circuit_graph: Circuit,
                            _ coupling_graph: Coupling,
                            _ init_layout: [RegBit:RegBit]? = nil,
                            _ b: String = "cx,u1,u2,u3,id",
                            _ verbose: Bool = false) throws -> (Circuit, [RegBit:RegBit]) {
        if circuit_graph.width() > coupling_graph.size() {
            throw MappingError.errorqubitscouplinggraph
        }
        var initial_layout = init_layout
        var basis = b
        // Schedule the input circuit
        let layerlist = try circuit_graph.layers()
        if verbose {
            print("schedule:")
            for i in 0..<layerlist.count {
                let partition = layerlist[i].partition
                var array: [String] = []
                for regBit in partition {
                    array.append(regBit.description)
                }
                print("    \(i): \(array.joined(separator: ","))")
            }
        }

        // Check input layout and create default layout if necessary
        var qubit_subset: [RegBit] = []
        if let init_layout = initial_layout {
            let circ_qubits = circuit_graph.get_qubits()
            let coup_qubits = coupling_graph.get_qubits()
            for (k, v) in init_layout {
                qubit_subset.append(v)
                if !circ_qubits.contains(k) {
                    throw MappingError.errorqubitinputcircuit(regBit: k)
                }
                if !coup_qubits.contains(v) {
                    throw MappingError.errorqubitincouplinggraph(regBit: v)
                }
            }
        }
        else {
            // Supply a default layout
            qubit_subset = coupling_graph.get_qubits()
            qubit_subset = Array(qubit_subset[0..<circuit_graph.width()])
            var init_layout: [RegBit:RegBit] = [:]
            let qubits = circuit_graph.get_qubits()
            for i in 0..<qubits.count {
                if i < qubit_subset.count {
                    init_layout[qubits[i]] = qubit_subset[i]
                }
                else {
                    break
                }
            }
            initial_layout = init_layout
        }

        // Find swap circuit to preceed to each layer of input circuit
        var layout = initial_layout!
        var openqasm_output = ""
        var first_layer = true  // True until first layer is output
        var first_swapping_layer = true  // True until first swap layer is output
        // Iterate over layers
        for i in 0..<layerlist.count {
            // Attempt to find a permutation for this layer
            let (success_flag, best_circ, best_d, best_layout, trivial_flag) =
                try Mapping.layer_permutation(layerlist[i].partition, layout, qubit_subset, coupling_graph, 20)
            // If this fails, try one gate at a time in this layer
            if !success_flag {
                if verbose {
                    print("swap_mapper: failed, layer \(i), retrying sequentially")
                }
                let serial_layerlist = try layerlist[i].graph.serial_layers()
                // Go through each gate in the layer
                for j in 0..<serial_layerlist.count {
                    let (success_flag, best_circ, best_d, best_layout, trivial_flag) =
                            try Mapping.layer_permutation(serial_layerlist[j].partition,
                                    layout, qubit_subset, coupling_graph,20)
                    // Give up if we fail again
                    if !success_flag {
                        throw MappingError.swapmapperfailed(i: i, j: j, qasm: try serial_layerlist[j].graph.qasm(no_decls: true,aliases:layout))
                    }
                    else {
                        // Update the qubit positions each iteration
                        let layout = best_layout
                        if best_d == 0 {
                            // Output qasm without swaps
                            if first_layer {
                                openqasm_output += try circuit_graph.qasm(decls_only: true, add_swap: true,aliases: layout)
                                first_layer = false
                            }
                            if !trivial_flag && first_swapping_layer {
                                initial_layout = layout
                                first_swapping_layer = false
                            }
                        }
                        else {
                            // Output qasm with swaps
                            if first_layer {
                                openqasm_output += try circuit_graph.qasm(decls_only: true, add_swap: true,aliases: layout)
                                first_layer = false
                                initial_layout = layout
                                first_swapping_layer = false
                            }
                            else {
                                if !first_swapping_layer {
                                    if verbose {
                                        print("swap_mapper: layer \(i) \(j)), depth \(String(describing: best_d))")
                                    }
                                    openqasm_output += best_circ ?? ""
                                }
                                else {
                                    initial_layout = layout
                                    first_swapping_layer = false
                                }
                            }
                            openqasm_output += try serial_layerlist[j].graph.qasm(no_decls: true,aliases: layout)
                        }
                    }
                }
            }
            else {
                // Update the qubit positions each iteration
                layout = best_layout!
                if best_d == 0 {
                    // Output qasm without swaps
                    if first_layer {
                        openqasm_output += try circuit_graph.qasm(decls_only: true, add_swap: true,aliases: layout)
                        first_layer = false
                    }
                    if !trivial_flag && first_swapping_layer {
                        initial_layout = layout
                        first_swapping_layer = false
                    }
                }
                else {
                    // Output qasm with swaps
                    if first_layer {
                        openqasm_output += try circuit_graph.qasm(decls_only: true, add_swap: true,aliases: layout)
                        first_layer = false
                        initial_layout = layout
                        first_swapping_layer = false
                    }
                    else {
                        if !first_swapping_layer {
                            if verbose {
                                print("swap_mapper: layer \(i), depth \(String(describing: best_d))")
                            }
                            openqasm_output += best_circ ?? ""
                        }
                        else {
                            initial_layout = layout
                            first_swapping_layer = false
                        }
                    }
                }
                openqasm_output += try layerlist[i].graph.qasm(no_decls: true,aliases: layout)
            }
        }
        // Parse openqasm_output into Circuit object
        basis += ",swap"
        let ast = Qasm(data: openqasm_output).parse()
        let u = Unroller(ast, CircuitBackend(basis.components(separatedBy:",")))
        u.execute()
        return ((u.backend as! CircuitBackend).circuit, initial_layout!)
    }

    /**
     Test if arguments are a solution to a system of equations.
     Cos[phi+lamb] * Cos[theta] = Cos[xi] * Cos[theta1+theta2]
     Sin[phi+lamb] * Cos[theta] = Sin[xi] * Cos[theta1-theta2]
     Cos[phi-lamb] * Sin[theta] = Cos[xi] * Sin[theta1+theta2]
     Sin[phi-lamb] * Sin[theta] = Sin[xi] * Sin[-theta1+theta2]
     Returns the maximum absolute difference between right and left hand sides.
     */
    static func test_trig_solution(_ theta: Double,
                                   _ phi: Double,
                                   _ lamb: Double,
                                   _ xi: Double,
                                   _ theta1: Double,
                                   _ theta2: Double) -> Double {
        let delta1 = cos(phi + lamb) * cos(theta) - cos(xi) * cos(theta1 + theta2)
        let delta2 = sin(phi + lamb) * cos(theta) - sin(xi) * cos(theta1 - theta2)
        let delta3 = cos(phi - lamb) * sin(theta) - cos(xi) * sin(theta1 + theta2)
        let delta4 = sin(phi - lamb) * sin(theta) - sin(xi) * sin(-theta1 + theta2)
        return max(abs(delta1), abs(delta2), abs(delta3), abs(delta4))
    }

    /**
     Express a Y.Z.Y single qubit gate as a Z.Y.Z gate.
     Solve the equation
     Ry(2*theta1).Rz(2*xi).Ry(2*theta2) = Rz(2*phi).Ry(2*theta).Rz(2*lambda)
     for theta, phi, and lambda. This is equivalent to solving the system
     given in the comment for test_solution. Use eps for comparisons with zero.
     Return a solution theta, phi, and lambda.
     */
    static func yzy_to_zyz(_ xi: Double,
                           _ theta1: Double,
                           _ theta2: Double,
                           _ eps: Double = 1e-9) -> (Double,Double,Double) {
        var solutions: [(Double,Double,Double)] = []  // list of potential solutions
        // Four cases to avoid singularities
        if abs(cos(xi)) < eps / 10 {
            solutions.append((theta2 - theta1, xi, 0.0))
        }
        else {
            if abs(sin(theta1 + theta2)) < eps / 10.0 {
                let phi_minus_lambda: [Double] = [Double.pi / 2.0 , 3.0 * Double.pi / 2.0, Double.pi / 2.0, 3.0 * Double.pi / 2.0]
                let stheta_1: Double = asin(sin(xi) * sin(-theta1 + theta2))
                let stheta_2: Double = asin(-sin(xi) * sin(-theta1 + theta2))
                let stheta_3: Double = Double.pi - stheta_1
                let stheta_4: Double = Double.pi - stheta_2
                let stheta: [Double] = [stheta_1, stheta_2, stheta_3, stheta_4]
                var phi_plus_lambda: [Double] = []
                for x in stheta {
                    phi_plus_lambda.append(acos(cos(theta1 + theta2) * cos(xi) / cos(x)))
                }
                var sphi: [Double] = []
                var slam: [Double] = []
                for i in 0..<phi_plus_lambda.count {
                    if i < phi_minus_lambda.count {
                        sphi.append((phi_plus_lambda[i] + phi_minus_lambda[i]) / 2.0)
                        slam.append((phi_plus_lambda[i] - phi_minus_lambda[i]) / 2.0)
                    }
                    else {
                        break
                    }
                }
                for i in 0..<stheta.count {
                    if i < sphi.count && i < slam.count {
                        solutions.append((stheta[i],sphi[i],slam[i]))
                    }
                    else {
                        break
                    }
                }
            }
            else {
                if abs(cos(theta1 + theta2)) < eps / 10.0 {
                    let phi_plus_lambda: [Double] = [Double.pi / 2.0, 3.0 * Double.pi / 2.0, Double.pi / 2.0, 3.0 * Double.pi / 2.0]
                    let stheta_1: Double = acos(sin(xi) * cos(theta1 - theta2))
                    let stheta_2: Double = acos(-sin(xi) * cos(theta1 - theta2))
                    let stheta_3: Double = -stheta_1
                    let stheta_4: Double = -stheta_2
                    let stheta: [Double] = [stheta_1, stheta_2, stheta_3, stheta_4]
                    var phi_minus_lambda: [Double] = []
                    for x in stheta {
                        phi_minus_lambda.append(acos(sin(theta1 + theta2) * cos(xi) / sin(x)))
                    }
                    var sphi: [Double] = []
                    var slam: [Double] = []
                    for i in 0..<phi_plus_lambda.count {
                        if i < phi_minus_lambda.count {
                            sphi.append((phi_plus_lambda[i] + phi_minus_lambda[i]) / 2.0)
                            slam.append((phi_plus_lambda[i] - phi_minus_lambda[i]) / 2.0)
                        }
                        else {
                            break
                        }
                    }
                    for i in 0..<stheta.count {
                        if i < sphi.count && i < slam.count {
                            solutions.append((stheta[i],sphi[i],slam[i]))
                        }
                        else {
                            break
                        }
                    }
                }
                else {
                    let phi_plus_lambda: Double = atan(sin(xi) * cos(theta1 - theta2) / (cos(xi) * cos(theta1 + theta2)))
                    let phi_minus_lambda: Double = atan(sin(xi) * sin(-theta1 + theta2) / (cos(xi) * sin(theta1 + theta2)))
                    let sphi: Double = (phi_plus_lambda + phi_minus_lambda) / 2.0
                    let slam: Double = (phi_plus_lambda - phi_minus_lambda) / 2.0
                    solutions.append((acos(cos(xi) * cos(theta1 + theta2) / cos(sphi + slam)), sphi, slam))
                    solutions.append((acos(cos(xi) * cos(theta1 + theta2) / cos(sphi + slam + Double.pi)), sphi + Double.pi / 2.0, slam + Double.pi / 2.0))
                    solutions.append((acos(cos(xi) * cos(theta1 + theta2) / cos(sphi + slam)), sphi + Double.pi / 2.0, slam - Double.pi / 2.0))
                    solutions.append((acos(cos(xi) * cos(theta1 + theta2) / cos(sphi + slam + Double.pi)), sphi + Double.pi, slam))
                }
            }
        }
        // Select the first solution with the required accuracy
        var deltas: [Double] = []
        for x in solutions {
            deltas.append(Mapping.test_trig_solution(x.0, x.1, x.2, xi, theta1, theta2))
        }
        for i in 0..<deltas.count {
            if i < solutions.count {
                if deltas[i] < eps {
                    return solutions[i]
                }
            }
            else {
                break
            }
        }
        print("xi=", xi)
        print("theta1=", theta1)
        print("theta2=", theta2)
        print("solutions=", solutions)
        print("deltas=", deltas)
        assert (false, "Error! No solution found. This should not happen.")
    }

    /**
     Return a triple theta, phi, lambda for the product.
     u3(theta, phi, lambda)
     = u3(theta1, phi1, lambda1).u3(theta2, phi2, lambda2)
     = Rz(phi1).Ry(theta1).Rz(lambda1+phi2).Ry(theta2).Rz(lambda2)
     = Rz(phi1).Rz(phi').Ry(theta').Rz(lambda').Rz(lambda2)
     = u3(theta', phi1 + phi', lambda2 + lambda')
     Return theta, phi, lambda.
     */
    static func compose_u3(_ theta1: Double,
                           _ phi1: Double,
                           _ lambda1: Double,
                           _ theta2: Double,
                           _ phi2: Double,
                           _ lambda2: Double) -> (Double, Double, Double) {
        // Careful with the factor of two in yzy_to_zyz
        let (thetap, phip, lambdap) = Mapping.yzy_to_zyz((lambda1 + phi2) / 2.0, theta1 / 2.0, theta2 / 2.0)
        return (2.0 * thetap, phi1 + 2.0 * phip, lambda2 + 2.0 * lambdap)
    }

    /**
     Cancel back-to-back "cx" gates in circuit.
     */
    static func cx_cancellation(_ circuit: Circuit) throws {
        let runs = try circuit.collect_runs(["cx"])
        for run in runs {
            // Partition the run into chunks with equal gate arguments
            var partition: [[GraphVertex<CircuitVertexData>]] = []
            var chunk: [GraphVertex<CircuitVertexData>] = []
            for i in 0..<(run.count-1) {
                chunk.append(run[i])
                let qargs0 = (run[i].data as! CircuitVertexOpData).qargs
                let qargs1 = (run[i + 1].data as! CircuitVertexOpData).qargs
                if qargs0 != qargs1 {
                    partition.append(chunk)
                    chunk = []
                }
            }
            chunk.append(run[run.count-1])
            partition.append(chunk)
            // Simplify each chunk in the partition
            for chunk in partition {
                if chunk.count % 2 == 0 {
                    for n in chunk {
                        circuit._remove_op_node(n.key)
                    }
                }
                else {
                    for i in 1..<chunk.count {
                        circuit._remove_op_node(chunk[i].key)
                    }
                }
            }
        }
    }

    /**
     "Simplify runs of single qubit gates in the QX basis.
     Return a new circuit that has been optimized.
     */
    static func optimize_1q_gates(_ circuit: Circuit) throws -> Circuit {
        let qx_basis = ["u1", "u2", "u3", "cx", "id"]
        let urlr = try Unroller(Qasm(data: circuit.qasm(qeflag: true)).parse(), CircuitBackend(qx_basis))
        urlr.execute()
        let unrolled = (urlr.backend as! CircuitBackend).circuit

        let runs = try unrolled.collect_runs(["u1", "u2", "u3", "id"])
        for run in runs {
            let qname = (run[0].data as! CircuitVertexOpData).qargs[0]
            var right_name = "u1"
            var right_parameters = (0.0, 0.0, 0.0)  // (theta, phi, lambda)
            for node in run {
                let nd = node.data as! CircuitVertexOpData
                assert(nd.condition == nil, "internal error")
                assert(nd.qargs.count == 1, "internal error")
                assert(nd.qargs[0] == qname, "internal error")
                var left_name = nd.name
                assert(Set<String>(["u1", "u2", "u3", "id"]).contains(left_name), "internal error")
                var left_parameters: (Double, Double, Double) = (0.0,0.0,0.0)
                if left_name == "u1" {
                    left_parameters = (0.0, 0.0, Double(nd.params[0])!)
                }
                else {
                    if left_name == "u2" {
                        left_parameters = (Double.pi / 2.0, Double(nd.params[0])!, Double(nd.params[1])!)
                    }
                    else {
                        if left_name == "u3" {
                            left_parameters = (Double(nd.params[0])!, Double(nd.params[1])!, Double(nd.params[2])!)
                        }
                        else {
                            left_name = "u1"  // replace id with u1
                            left_parameters = (0.0, 0.0, 0.0)
                        }
                    }
                }
                // Compose gates
                let name_tuple = (left_name, right_name)
                if name_tuple == ("u1", "u1") {
                    // u1(lambda1) * u1(lambda2) = u1(lambda1 + lambda2)
                    right_parameters = (0.0, 0.0, right_parameters.2 + left_parameters.2)
                }
                else {
                    if name_tuple == ("u1", "u2") {
                        // u1(lambda1) * u2(phi2, lambda2) = u2(phi2 + lambda1, lambda2)
                        right_parameters = (Double.pi / 2, right_parameters.1 + left_parameters.2, right_parameters.2)
                    }
                    else {
                        if name_tuple == ("u2", "u1") {
                            // u2(phi1, lambda1) * u1(lambda2) = u2(phi1, lambda1 + lambda2)
                            right_name = "u2"
                            right_parameters = (Double.pi / 2.0, left_parameters.1, right_parameters.2 + left_parameters.2)
                        }
                        else {
                            if name_tuple == ("u1", "u3") {
                                // u1(lambda1) * u3(theta2, phi2, lambda2) =
                                //     u3(theta2, phi2 + lambda1, lambda2)
                                right_parameters = (right_parameters.0, right_parameters.1 + left_parameters.2, right_parameters.2)
                            }
                            else {
                                if name_tuple == ("u3", "u1") {
                                    // u3(theta1, phi1, lambda1) * u1(lambda2) =
                                    //    u3(theta1, phi1, lambda1 + lambda2)
                                    right_name = "u3"
                                    right_parameters = (left_parameters.0, left_parameters.1, right_parameters.2 + left_parameters.2)
                                }
                                else {
                                    if name_tuple == ("u2", "u2") {
                                        // Using Ry(pi/2).Rz(2*lambda).Ry(pi/2) =
                                        //    Rz(pi/2).Ry(pi-2*lambda).Rz(pi/2),
                                        // u2(phi1, lambda1) * u2(phi2, lambda2) =
                                        //    u3(pi - lambda1 - phi2, phi1 + pi/2, lambda2 + pi/2)
                                        right_name = "u3"
                                        right_parameters = (Double.pi - left_parameters.2 - right_parameters.1, left_parameters.1 + Double.pi / 2.0, right_parameters.2 + Double.pi / 2)
                                    }
                                    else {
                                        // For composing u3's or u2's with u3's, use
                                        // u2(phi, lambda) = u3(pi/2, phi, lambda)
                                        // together with the qiskit.mapper.compose_u3 method.
                                        right_name = "u3"
                                        right_parameters = Mapping.compose_u3(left_parameters.0,
                                                                        left_parameters.1,
                                                                        left_parameters.2,
                                                                        right_parameters.0,
                                                                        right_parameters.1,
                                                                        right_parameters.2)
                                    }
                                }
                            }
                        }
                    }
                }
                // Here down, when we simplify, we add f(theta) to lambda to correct
                // the global phase when f(theta) is 2*pi. This isn't necessary but
                // the other steps preserve the global phase, so we continue.
                let epsilon = 1e-9  // for comparison with zero
                // Y rotation is 0 mod 2*pi, so the gate is a u1
                if abs(right_parameters.0.truncatingRemainder(dividingBy: 2.0) * Double.pi) < epsilon && right_name != "u1" {
                    right_name = "u1"
                    right_parameters = (0.0, 0.0, right_parameters.1 + right_parameters.2 + right_parameters.0)
                }
                // Y rotation is pi/2 or -pi/2 mod 2*pi, so the gate is a u2
                if right_name == "u3" {
                    // theta = pi/2 + 2*k*pi
                    if abs((right_parameters.0 - Double.pi / 2.0).truncatingRemainder(dividingBy: 2.0) * Double.pi) < epsilon {
                        right_name = "u2"
                        right_parameters = (Double.pi / 2.0, right_parameters.1, right_parameters.2 + (right_parameters.0 - Double.pi / 2.0))
                    }
                    // theta = -pi/2 + 2*k*pi
                    if abs((right_parameters.0 + Double.pi / 2.0).truncatingRemainder(dividingBy: 2.0) * Double.pi) < epsilon {
                        right_name = "u2"
                        right_parameters = (Double.pi / 2.0, right_parameters.1 + Double.pi, right_parameters.2 - Double.pi + (right_parameters.0 + Double.pi / 2.0))
                    }
                }
                // u1 and lambda is 0 mod 4*pi so gate is nop
                if right_name == "u1" && abs(right_parameters.2.truncatingRemainder(dividingBy: 4.0) * Double.pi) < epsilon {
                    right_name = "nop"
                }
            }
            // Replace the data of the first node in the run
            var new_params: [String] = []
            if right_name == "u1" {
                new_params.append(String(right_parameters.2))
            }
            if right_name == "u2" {
                new_params = [String(right_parameters.1), String(right_parameters.2)]
            }
            if right_name == "u3" {
                new_params = [String(right_parameters.0), String(right_parameters.1), String(right_parameters.2)]
            }
            (run[0].data as! CircuitVertexOpData).name = right_name
            (run[0].data as! CircuitVertexOpData).params = new_params
            // Delete the other nodes in the run
            for i in 1..<run.count {
                unrolled._remove_op_node(run[i].key)
            }
            if right_name == "nop" {
                unrolled._remove_op_node(run[0].key)
            }
        }
        return unrolled
    }
}
