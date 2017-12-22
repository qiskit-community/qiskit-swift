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
 A collection of useful quantum information functions.

 Currently this file is very sparse. More functions will be added
 over time.
  */
 public final class QI {

     private init() {
     }

    //###############################################################
    //# circuit manipulation.
    //###############################################################

    // Define methods for making QFT circuits
    /**
     n-qubit QFT on q in circ.
     */
    public static func qft(_ circ: QuantumCircuit, _ q: QuantumRegister, _ n: Int) throws {
        for j in 0..<n {
            for k in 0..<j {
                try circ.cu1(Double.pi/Double(pow(2.0,Double(j-k))), q[j], q[k])
            }
            try circ.h(q[j])
        }
    }

    //###############################################################
    //# State manipulation.
    //###############################################################

    /**
     Partial trace over subsystems of multi-partite matrix.

     Note that subsystems are ordered as rho012 = rho0(x)rho1(x)rho2.

     Args:
         state (NxN matrix_like): a matrix
         sys (list(int): a list of subsystems (starting from 0) to trace over
         dims (list(int), optional): a list of the dimensions of the subsystems.
         If this is not set it will assume all subsystems are qubits.
         reverse (bool, optional): ordering of systems in operator.
         If True system-0 is the right most system in tensor product.
         If False system-0 is the left most system in tensor product.

     Returns:
        A matrix with the appropriate subsytems traced over.
     */
    public static func partial_trace(_ state: [Any],
                                     sys: Any,
                                     dims: [Int]? = nil,
                                     _ reverse: Bool = true) throws -> Matrix<Complex> {
        // convert op to density matrix
        var rho = Matrix<Complex>()
        if let s = state as? [Complex] {
            rho = QI.outer(Vector<Complex>(value:s))  // convert state vector to density mat
        }
        else if let s = state as? [[Complex]] {
            rho = Matrix<Complex>(value:s)
        }
        else {
            throw ToolsError.errorPartialTrace
        }
        // compute dims if not specified
        var dimensions = Vector<Int>()
        if let d = dims {
            dimensions = Vector<Int>(value:d)
        }
        else {
            let n = log2(Double(rho.rowCount))
            dimensions = Vector<Int>(repeating: 2, count:Int(n))
            if Double(rho.rowCount) != pow(2.0,n) {
                throw ToolsError.errorPartialTrace
            }
        }

        // reverse sort trace sys
        var subsystems: [Int] = []
        if let s = sys as? Int {
            subsystems = [s]
        }
        else if let s = sys as? [Int] {
            subsystems = s.reversed()
        }
        else {
            throw ToolsError.errorSubsystem
        }

        // trace out subsystems
        for j in subsystems {
            // get trace dims
            var dpre = Vector<Int>()
            var dpost = Vector<Int>()
            if reverse {
                dpre = Vector<Int>(value: Array(dimensions.value[(j + 1)...]))
                dpost = Vector<Int>(value: Array(dimensions.value[..<j]))
            }
            else {
                dpre = Vector<Int>(value: Array(dimensions.value[..<j]))
                dpost = Vector<Int>(value: Array(dimensions.value[(j + 1)...]))
            }
            let dim1 = dpre.prod()
            let dim2 = dimensions[j]
            let dim3 = dpost.prod()
            // dims with sys-j removed
            dimensions = dpre + dpost
            // do the trace over j
            rho = try QI.__trace_middle(rho, dim1, dim2, dim3)
        }
        return rho
    }

    /**
     Get system dimensions for __trace_middle.

     Args:
         j (int): system to trace over.
         dims(list[int]): dimensions of all subsystems.
         reverse (bool): if true system-0 is right-most system tensor product.

     Returns:
        Tuple (dim1, dims2, dims3)
     */
    private static func __trace_middle_dims(_ sys: Int,
                                            _ dims: [Int],
                                            reverse: Bool = true) -> (Int,Int,Int) {
        var dpre = Vector<Int>(value: Array(dims[..<sys]))
        var dpost = Vector<Int>(value: Array(dims[(sys + 1)...]))
        if reverse {
            let temp = dpre
            dpre  = dpost
            dpost = temp
        }
        let dim1 = dpre.prod()
        let dim2 = dims[sys]
        let dim3 = dpost.prod()
        return (dim1, dim2, dim3)
    }

    /**
     Partial trace over middle system of tripartite state.

     Args:
         op (NxN matrix_like): a tri-partite matrix
         dim1: dimension of the first subsystem
         dim2: dimension of the second (traced over) subsystem
         dim3: dimension of the third subsystem

     Returns:
        A (D,D) matrix where D = dim1 * dim3
    */
    private static func __trace_middle(_ op: Matrix<Complex>,
                                      _ dim1: Int = 1,
                                      _ dim2: Int = 1,
                                      _ dim3: Int = 1) throws  -> Matrix<Complex> {
        let m = try op.reshape([dim1,dim2,dim3,dim1,dim2,dim3])
        let d = dim1 * dim3
        return Matrix<Complex>(value:try m.trace(axis1: 1, axis2: 4).reshape([d, d]).value as! [[Complex]])
    }

    /**
     Flatten an operator to a vector in a specified basis.

     Args:
         rho (ndarray): a density matrix.
         method (str): the method of vectorization. Allowed values are
         - 'col' (default) flattens to column-major vector.
         - 'row' flattens to row-major vector.
         - 'pauli'flattens in the n-qubit Pauli basis.
         - 'pauli-weights': flattens in the n-qubit Pauli basis ordered by
         weight.

     Returns:
        ndarray: the resulting vector.
    */
    public static func vectorize(_ rho: Matrix<Complex>, method: String = "col") throws -> Vector<Complex> {
        if method == "col" {
            return rho.flattenCol()
        }
        else if method == "row" {
            return rho.flattenRow()
        }
        else if Set<String>(["pauli", "pauli_weights"]).contains(method) {
            let num = Int(log2(Double(rho.rowCount)))  // number of qubits
            if Double(rho.rowCount) != pow(2.0,Double(num)) {
                throw ToolsError.errorVectorize
            }
            var pgroup: [Pauli] = []
            if method == "pauli_weights" {
                pgroup = try Pauli.pauli_group(num, 0)
            }
            else {
                pgroup = try Pauli.pauli_group(num, 1)
            }
            var vals = Vector<Complex>()
            for p in pgroup {
                vals.append(try p.to_matrix().dot(rho).trace())
            }
            return vals
        }
        else {
            throw ToolsError.invalidMethod(method: method)
        }
    }

    /**
     Devectorize a vectorized square matrix.

     Args:
         vec (ndarray): a vectorized density matrix.
         basis (str): the method of devectorizaation. Allowed values are
         - 'col' (default): flattens to column-major vector.
         - 'row': flattens to row-major vector.
         - 'pauli': flattens in the n-qubit Pauli basis.
         - 'pauli-weights': flattens in the n-qubit Pauli basis ordered by
         weight.

     Returns:
        ndarray: the resulting matrix.
    */
  /*  public static func devectorize(_ vec: Vector<Complex> , method: String = "col") throws -> Matrix<Complex> {
        let d = Int(Double(vec.count).squareRoot())  // the dimension of the matrix
        if vec.count != d*d {
            throw ToolsError.errorVectorizedMatrix
        }
        if method == "col"{
            return vec.reshape(d, d, order:"F")
        }
        else if method == "row" {
            return vec.reshape(d, d, order:"C")
        }
        else if Set<String>(["pauli", "pauli_weights"]).contains(method) {
            let num = Int(log2(Double(d)))  // number of qubits
            if d != Int(pow(2.0,Double(num))) {
                throw ToolsError.errorVectorize
            }
            var pgroup: [Pauli] = []
            if method == "pauli_weights" {
                pgroup = try Pauli.pauli_group(num, 0)
            }
            else {
                pgroup = try Pauli.pauli_group(num, 1)
            }
            var pbasis: [Matrix<Complex>] = []
            for p in pgroup {
                pbasis.append(try p.to_matrix().div(Complex(real:pow(2.0,Double(num)))))
            }
            return np.tensordot(vec, pbasis, axes: 1)
        }
        else {
            throw ToolsError.invalidMethod(method: method)
        }
    }*/

    /**
     Convert a Choi-matrix to a Pauli-basis superoperator.

     Note that this function assumes that the Choi-matrix
     is defined in the standard column-stacking converntion
     and is normalized to have trace 1. For a channel E this
     is defined as: choi = (I \otimes E)(bell_state).

     The resulting 'rauli' R acts on input states as
     |rho_out>_p = R.|rho_in>_p
     where |rho> = vectorize(rho, method='pauli') for order=1
     and |rho> = vectorize(rho, method='pauli_weights') for order=0.

     Args:
         Choi (matrix): the input Choi-matrix.
         order (int, optional): ordering of the Pauli group vector.
         order=1 (default) is standard lexicographic ordering.
         Eg: [II, IX, IY, IZ, XI, XX, XY,...]
         order=0 is ordered by weights.
         Eg. [II, IX, IY, IZ, XI, XY, XZ, XX, XY,...]

     Returns:
        A superoperator in the Pauli basis.
    */
/*    public static func choi_to_rauli(_ choi: Matrix<Complex>, _ order: Int = 1) throws {
        // get number of qubits'
        let n = Int(log2(np.sqrt(Double(choi.rowCount)).squareRoot()))
        let pgp = try Pauli.pauli_group(n, order)
        var rauli = []
        for i in pgp {
            for j in pgp {
                pauliop = np.kron(j.to_matrix().T, i.to_matrix())
                rauli += [np.trace(np.dot(choi, pauliop))]
            }
        }
        return np.array(rauli).reshape(4 ** n, 4 ** n)
    }
*/
    /**
     Truncate small values of a complex array.

     Args:
        op (array_like): array to truncte small values.
        epsilon (float): threshold.

     Returns:
        A new operator with small values set to zero.
     */
    public static func chop(_ op: [Complex], _ epsilon: Double = 1e-10) -> [Complex] {
        var vec = op
        for i in 0..<vec.count {
            var complex = vec[i]
            if abs(complex.real) < epsilon {
                complex.real = 0.0
            }
            if abs(complex.imag) < epsilon {
                complex.imag = 0.0
            }
            vec[i] = complex
        }
        return vec
    }

    /**
     Construct the outer product of two vectors.

     The second vector argument is optional, if absent the projector
     of the first vector will be returned.

     Args:
        v1 (ndarray): the first vector.
        v2 (ndarray): the (optional) second vector.

     Returns:
        The matrix |v1><v2|.
    */
    public static func outer(_ v1: Vector<Complex>, _ v2: Vector<Complex>? = nil) -> Matrix<Complex> {
        var u = Vector<Complex>()
        if let v = v2 {
            u = v.conjugate()
        }
        else {
            u = v1.conjugate()
        }
        return v1.outer(u)
    }

    //###############################################################
    //# Measures.
    //###############################################################

    /**
     Apply real scalar function to singular values of a matrix.

     Args:
        a : (N, N) array_like
            Matrix at which to evaluate the function.
        func : callable
        Callable object that evaluates a scalar function f.

     Returns:
        funm : (N, N) ndarray
        Value of the matrix function specified by func evaluated at `A`.
     */
/*    public static func funm_svd(_ a: Matrix<Double>, _ f: ((_:[Double]) -> [Double]) ) {
        U, s, Vh = la.svd(a, lapack_driver="gesvd")
        S = np.diag(func(s))
        return U.dot(S).dot(Vh)
    }

    /**
     Return the state fidelity between two quantum states.

     Either input may be a state vector, or a density matrix.

     Args:
        state1: a quantum state vector or density matrix.
        state2: a quantum state vector or density matrix.

     Returns:
        The state fidelity F(state1, state2).
     */
    public static func state_fidelity(_ state1, _ state2) {
        // convert input to numpy arrays
        s1 = np.array(state1)
        s2 = np.array(state2)

        // fidelity of two state vectors
        if s1.ndim == 1 && s2.ndim == 1 {
            return np.abs(s2.conj().dot(s1))
        }
        // fidelity of vector and density matrix
        else if s1.ndim == 1 {
            // psi = s1, rho = s2
            return np.sqrt(np.abs(s1.conj().dot(s2).dot(s1)))
        }
        else if s2.ndim == 1 {
            // psi = s2, rho = s1
            return np.sqrt(np.abs(s2.conj().dot(s1).dot(s2)))
        }
        // fidelity of two density matrices
        else {
            s1sq = funm_svd(s1, np.sqrt)
            s2sq = funm_svd(s2, np.sqrt)
            return np.linalg.norm(s1sq.dot(s2sq), ord="nuc")
        }
    }

    /**
     Calculate the purity of a quantum state.

     Args:
        state (np.array): a quantum state
     Returns:
        purity.
     */
    public static func purity(_ state) {
        rho = np.array(state)
        if rho.ndim == 1 {
            rho = outer(rho)
        }
        return np.real(np.trace(rho.dot(rho)))
    }

    /**
     Calculate the concurrence.

     Args:
        state (np.array): a quantum state
     Returns:
        concurrence.
     */
    public static func concurrence(_ state) throws {
        rho = np.array(state)
        if rho.ndim == 1 {
            rho = outer(state)
        }
        if len(state) != 4 {
            throw ToolsError.errorConcurrence
        }
        YY = np.fliplr(np.diag([-1, 1, 1, -1]))
        A = rho.dot(YY).dot(rho.conj()).dot(YY)
        w = la.eigh(A, eigvals_only=True)
        w = np.sqrt(np.maximum(w, 0))
        return max(0.0, w[-1]-np.sum(w[0:-1]))
    }

    //###############################################################
    //# Other.
    //###############################################################

    public static func is_pos_def(_ x: Matrix<Complex>) {
        return np.all(np.linalg.eigvals(x) > 0)
    }*/
}
