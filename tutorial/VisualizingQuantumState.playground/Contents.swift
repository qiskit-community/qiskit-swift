/*:
 [QISKit Swift Tutorial]:https://github.com/QISKit/qiskit-sdk-swift/tree/master/tutorial "QISKit SDK Tutotial"

 ## Visualizing a Quantum State
 The latest version of this notebook is available on [QISKit Swift Tutorial].

 ### Acknowledgement
 [QISKit Python Tutorial]: https://github.com/QISKit/qiskit-tutorial/blob/master/1_introduction/visualizing_quantum_state.ipynb "QISKit Python Tutotial"

 This tutorial is based on the one with same name on [QISKit Python Tutorial].
 */
import PlaygroundSupport
import qiskit
import XCPlayground
/*:
 ### The outcomes of a quantum circuit
 In quantum you can not measure a state without disturbing it. The act of measurement changes the state. After performing a quantum measurement, a qubit's information becomes a classical bit, and in our system (as is standard) the measurements are performed in the computational basis. For each qubit the measurement either takes the value 0 if the qubit is measured in state |0> and value 1 if the qubit is measured in state |1>.

 In a given run of a quantum circuit with measurements, the result will be one of the possible n-bit binary strings. If the experiment is run a second time, even if the measurement is perfect and has no error, the outcome may be different due to the fundamental randomness of quantum physics. The results of a quantum circuit executed many different times can be represented as a distribution over the possible outcomes. For a quantum circuit which has previously ran on a backend with name "circuit" this histogram can be obtained using:

 ```
 PlaygroundPage.current.liveView = plot_histogram(try result.get_counts("circuit"))
 ```

 The histogram/bar graph is simple to understand. The height of the bar represents the fraction of instances the outcome comes up in the different runs on the backend. To demonstrate this we make two circuits a GHZ state and a superposition over 3 qubits.
 */
// Build the quantum cirucit. We are going to build two circuits a GHZ over 3 qubits and a
// superpositon over all 3 qubits

let containerLiveView = ContainerLiveView(height: 600)

do {
    let Q_program = try QuantumProgram()
    let n = 3  // number of qubits
    let q = try Q_program.create_quantum_register("q", n)
    let c = try Q_program.create_classical_register("c", n)

    // quantum circuit to make a GHZ state
    let ghz_name = "ghz"
    let ghz = try Q_program.create_circuit(ghz_name, [q], [c])
    try ghz.h(q[0])
    try ghz.cx(q[0], q[1])
    try ghz.cx(q[0], q[2])
    try ghz.s(q[0])
    try ghz.measure(q[0], c[0])
    try ghz.measure(q[1], c[1])
    try ghz.measure(q[2], c[2])
    print(ghz.qasm())

    // quantum circuit to make a superpostion state
    let superposition_name = "superposition"
    let superposition = try Q_program.create_circuit(superposition_name, [q], [c])
    try superposition.h(q)
    try superposition.s(q[0])
    try superposition.measure(q[0], c[0])
    try superposition.measure(q[1], c[1])
    try superposition.measure(q[2], c[2])
    print(superposition.qasm())

    let circuits = [ghz_name, superposition_name]

    // execute the quantum circuit
    var backend = "local_qasm_simulator" // the device to run on
    Q_program.execute(circuits, backend: backend, shots: 1000) { (result) in
        if let error = result.get_error() {
            print(error)

            return
        }

        do {
            let ghz_histogram = plot_histogram(try result.get_counts(ghz_name))
            containerLiveView.insertSubview(ghz_histogram, at: 0)

            let superposition_histogram = plot_histogram(try result.get_counts(superposition_name))
            containerLiveView.insertSubview(superposition_histogram, at: 1)

            PlaygroundPage.current.liveView = containerLiveView
        } catch {
            print(error)
        }
    }
/*:
 ### Method for visualizing a quantum state
 [quantum state tomography]:https://github.com/QISKit/qiskit-tutorial/blob/722f076052b7fc0c5e92cd26631c9983ef3320a3/3_qcvv/state_tomography.ipynb "quantum state tomography"

 For educational and debugging purposes it is useful to visualize a quantum state, ρ. Experimentally to reconstruct a quantum state we have to perform 4^n - 1 different experiments, where n is the number of qubits and combined them using a process known as [quantum state tomography] to estimate the quantum state.

 #### pure states
 A pure state |Ψ> is an element of H, where H is known as a Hilbert space. For n-qubits the Hilbert space consists of a complex vector space C^d of dimensions d=2^n and we denote the inner product by <Φ|Ψ>.

 #### operators
 In order to relate the state to quantities of physical interest we need to introduce operators. An operator is an object which maps a Hilbert space into itself.

 #### mixed states
 ρ is the most general type of quantum state known as a mixed state or state operator. A quantum state operator must obey the following three constraints:
 1. Normalized
 2. Hermitian
 3. positive semi-definite

 The real and imaginary matrix elements ρ_i,j represent the standard representation of a quantum state and we have provided the following function to plot them:

 ```
 PlaygroundPage.current.liveView = plot_state(rho, .city)
 ```

 which makes two 2-dimensional bargraphs (real and imaginary part).

 The pauli basis which consists of 4^n operators formed by the tensor product of pauli operators I, X, Y, Z gives a basis which has only real coefficients. To plot a bar graph of these coefficients we have provided the method:

 ```
 PlaygroundPage.current.liveView = plot_state(rho, .paulivec)
 ```

 Lastly we provide the method:

 ```
 PlaygroundPage.current.liveView = plot_state(rho, .qsphere)
 ```

 which plots the qspheres of the quantum state. The QSphere is divided into n+1 levels, and each section represents the weight (total number of 1s) of the binary outcome. The top is the |0...0> state, the next line is all the states with a single 1 (|1...0>, |0...1> , etc), the line after that is all states with two 1s, and so on until the bottom is the state |1...1>.

 The usefulness of this representation is it is more compact for quantum states that are close to pure states.

 As an example we consider the same states as above.
 */
    // execute the quantum circuit
    backend = "local_unitary_simulator" // the device to run on
    Q_program.execute(circuits, backend: backend, shots: 1000) { (result) in
        if let error = result.get_error() {
            print(error)

            return
        }

        let groundRows = Int(truncating: NSDecimalNumber(decimal: Decimal(pow(Double(2), Double(n)))))
        var ground = Matrix(repeating: Complex(integerLiteral: 0), rows: groundRows, cols: 1)
        ground[0, 0] = Complex(integerLiteral: 1)

        do {
            guard let ghz_unitary = try result.get_data(ghz_name)["unitary"] as? Matrix<Complex>,
                let superposition_unitary = try result.get_data(superposition_name)["unitary"] as? Matrix<Complex> else {
                    print("Unable to get unitary matrices")

                    return
            }

            let state_ghz = ghz_unitary.dot(ground)
            let flatten_state_ghz = state_ghz.flattenRow()
            let rho_ghz = flatten_state_ghz.outer(flatten_state_ghz.conjugate())

            let ghz_city = plot_state(rho_ghz, .city)
            containerLiveView.insertSubview(ghz_city, at: 2)

            let ghz_paulivec = plot_state(rho_ghz, .paulivec)
            containerLiveView.insertSubview(ghz_paulivec, at: 3)

            let ghz_qsphere = plot_state(rho_ghz, .qsphere)
            containerLiveView.insertSubview(ghz_qsphere, at: 4)

            let state_superposition = superposition_unitary.dot(ground)
            let flatten_state_superposition = state_superposition.flattenRow()
            let rho_superposition = flatten_state_superposition.outer(flatten_state_superposition.conjugate())

            let superposition_city = plot_state(rho_superposition, .city)
            containerLiveView.insertSubview(superposition_city, at: 5)

            let superposition_paulivec = plot_state(rho_superposition, .paulivec)
            containerLiveView.insertSubview(superposition_paulivec, at: 6)

            let superposition_qsphere = plot_state(rho_superposition, .qsphere)
            containerLiveView.insertSubview(superposition_qsphere, at: 7)

            let superposition_bloch = plot_state(rho_superposition, .bloch)
            containerLiveView.insertSubview(superposition_bloch, at: 8)

            let rho_superposition_by_half = rho_superposition.mult(Complex(0.5, 0))
            let rho_ghz_by_half = rho_ghz.mult(Complex(0.5, 0))
            let added_rho = try rho_superposition_by_half.add(rho_ghz_by_half)
            let added_qsphere = plot_state(added_rho, .qsphere)
            containerLiveView.insertSubview(added_qsphere, at: 9)

            PlaygroundPage.current.liveView = containerLiveView
        } catch {
            print(error)
        }
    }
} catch {
    print(error)
}

PlaygroundPage.current.needsIndefiniteExecution = true

