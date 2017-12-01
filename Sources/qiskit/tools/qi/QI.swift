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
 /*   public static func partial_trace(_ state: [[Complex]],
                                     _ sys: [Int],
                                     _ dims: [Int]? = nil,
                                     _ reverse: Bool = true) throws -> Matrix<Complex> {
        // convert op to density matrix
        var rho = Matrix<Complex>(value:state)
        if rho.rowCount == 1 {
            rho = QI.outer(rho)  // convert state vector to density mat
        }
        // compute dims if not specified
        if dims == nil {
            let n = Int(log2(Double(rho.rowCount)))
            dims = Array(repeating: 2, count:n)
            if rho.rowCount != pow(2.0,n) {
                throw ToolsError.errorPartialTrace
            }
        }
        else {
            dims = list(dims)
        }

        // reverse sort trace sys
        if isinstance(sys, int) {
            sys = [sys]
        }
        else {
            sys = QI.sorted(sys, reverse: true)
        }

        // trace out subsystems
        for j in sys {
            // get trace dims
            if reverse {
                dpre = dims[j + 1:]
                dpost = dims[:j]
            }
            else {
                dpre = dims[:j]
                dpost = dims[j + 1:]
            }
            dim1 = int(np.prod(dpre))
            dim2 = int(dims[j])
            dim3 = int(np.prod(dpost))
            // dims with sys-j removed
            dims = dpre + dpost
            // do the trace over j
            rho = QI.__trace_middle(rho, dim1, dim2, dim3)
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
        var dpre = dims[:sys]
        var dpost = dims[sys + 1:]
        if reverse {
            var temp = dpre
            dpre  = dpost
            dpost = temp
        }
        dim1 = Int(np.prod(dpre))
        dim2 = Int(dims[sys])
        dim3 = Int(np.prod(dpost))
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
    public static func __trace_middle(_ op: Matrix<Complex>,
                                      _ dim1: Int = 1,
                                      _ dim2: Int = 1,
                                      _ dim3: Int = 1) {
        let op = op.reshape(dim1, dim2, dim3, dim1, dim2, dim3)
        d = dim1 * dim3
        return op.trace(axis1=1, axis2=4).reshape(d, d)
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
    public static func vectorize(_ rho: Matrix<Complex>, _ method: String = "col") {
        rho = np.array(rho)
        if method == "col":
        return rho.flatten(order='F")
        elif method == "row":
        return rho.flatten(order="C")
        elif method in ["pauli", "pauli_weights"]:
        num = int(np.log2(len(rho)))  # number of qubits
        if len(rho) != 2**num:
        raise Exception("Input state must be n-qubit state")
        if method is "pauli_weights":
        pgroup = pauli_group(num, case=0)
        else:
        pgroup = pauli_group(num, case=1)
        vals = [np.trace(np.dot(p.to_matrix(), rho)) for p in pgroup]
        return np.array(vals)
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
    public static func devectorize(vec: , method="col") {
        vec = np.array(vec)
        d = int(np.sqrt(vec.size))  // the dimension of the matrix
        if len(vec) != d*d:
        raise Exception("Input is not a vectorized square matrix")

        if method == "col":
        return vec.reshape(d, d, order="F")
        elif method == "row":
        return vec.reshape(d, d, order="C")
        elif method in ["pauli", "pauli_weights"]:
        num = int(np.log2(d))  # number of qubits
        if d != 2 ** num:
        raise Exception("Input state must be n-qubit state")
        if method is "pauli_weights":
        pgroup = pauli_group(num, case=0)
        else:
        pgroup = pauli_group(num, case=1)
        pbasis = np.array([p.to_matrix() for p in pgroup]) / 2 ** num
        return np.tensordot(vec, pbasis, axes=1)
    }

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
    public static func choi_to_rauli(choi, order=1) {
        // get number of qubits'
        n = int(np.log2(np.sqrt(len(choi))))
        pgp = pauli_group(n, case=order)
        rauli = []
        for i in pgp:
        for j in pgp:
        pauliop = np.kron(j.to_matrix().T, i.to_matrix())
        rauli += [np.trace(np.dot(choi, pauliop))]
        return np.array(rauli).reshape(4 ** n, 4 ** n)
    }

    /**
     Truncate small values of a complex array.

     Args:
        op (array_like): array to truncte small values.
        epsilon (float): threshold.

     Returns:
        A new operator with small values set to zero.
     */
    public static func chop(op, epsilon=1e-10) {
        op.real[abs(op.real) < epsilon] = 0.0
        op.imag[abs(op.imag) < epsilon] = 0.0
        return op
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
    public static func outer(_ v1, _ v2 = nil) {
        if v2 is None:
        u = np.array(v1).conj()
        else:
        u = np.array(v2).conj()
        return np.outer(v1, u)
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
    public static func funm_svd(a, func) {
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
    public static func state_fidelity(state1, state2) {
        // convert input to numpy arrays
        s1 = np.array(state1)
        s2 = np.array(state2)

        // fidelity of two state vectors
        if s1.ndim == 1 and s2.ndim == 1:
        return np.abs(s2.conj().dot(s1))
        // fidelity of vector and density matrix
        elif s1.ndim == 1:
        // psi = s1, rho = s2
        return np.sqrt(np.abs(s1.conj().dot(s2).dot(s1)))
        elif s2.ndim == 1:
        // psi = s2, rho = s1
        return np.sqrt(np.abs(s2.conj().dot(s1).dot(s2)))
        // fidelity of two density matrices
        else:
        s1sq = funm_svd(s1, np.sqrt)
        s2sq = funm_svd(s2, np.sqrt)
        return np.linalg.norm(s1sq.dot(s2sq), ord="nuc")
    }

    /**
     Calculate the purity of a quantum state.

     Args:
        state (np.array): a quantum state
     Returns:
        purity.
     */
    public static func purity(state) {
        rho = np.array(state)
        if rho.ndim == 1:
        rho = outer(rho)
        return np.real(np.trace(rho.dot(rho)))
    }

    /**
     Calculate the concurrence.

     Args:
        state (np.array): a quantum state
     Returns:
        concurrence.
     */
    public static func concurrence(state) {
        rho = np.array(state)
        if rho.ndim == 1:
        rho = outer(state)
        if len(state) != 4:
        raise Exception("Concurence is not defined for more than two qubits")

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
