/*:
 [QISKit Swift Tutotial]:https://github.com/QISKit/qiskit-sdk-swift/tree/master/tutorial "QISKit SDK Tutotial"

 ## Quantum Emoticon
 The latest version of this notebook is available on [QISKit Swift Tutotial].


 ### Acknowledgement
 [QISKit Python Tutotial]: https://github.com/QISKit/qiskit-tutorial/blob/master/0_hello_world/quantum_emoticon.ipynb "QISKit Python Tutotial"
 [Bell state]: https://github.com/QISKit/qiskit-tutorial/blob/master/2_quantum_information/superposition_and_entanglement.ipynb "Bell state"

 This tutorial is based on (in fact, it is a copy from) the one contributed by James R. Wootton, University of Basel on [QISKit Python Tutotial].

 This program aims to do some of the same jobs as "Hello World" does for classical programming.

 Specifically:
 * It is simple;
 * It performs and understandable and relatable task;
 * It demonstrates simple principles of the programming language;
 * It shows how to produce and look at an output.

 Anything that can be done with bits can be done with qubits. Simply leave a qubit in its initialized value for the state _0_, or use an operation with the effect of a NOT gate (such as X or Y) to rotate it to a _1_. Each qubit then becomes a bit, allowing us to implement "Hello, World!" directly on a quantum computer.

 In practice, it is not so straightforward. ASCII encoding of "Hello, World!" requires over 100 bits, and therefore over 100 qubits. Current quantum devices are not yet large enough for the job.

 However, two ASCII characters require only 16 (qu)bits.

 The string corresponding to ;) is

    ;)  =  '0011101100101001'

 To prepare this state we can perform an X on qubits 0, 3, 5, 8, 9, 11, 12, 13. Here we number the bits from 0 to 15, from right to left.

 Of course, just writing a bit string in some qubits isn't very quantum. Instead we can prepare a superposition of two different emoticons. We choose ;) and 8), which correspond to the bit strings

    8)  =  '0011100000101001'
    ;)  =  '0011101100101001'

 Note that these strings differ only on bits 8 and 9. It is therefore only these on which the superposition must be prepared. The superposition will be of the '00' of 8), and the '11' of ;) , and so will be a standard [Bell state].

 We'll now implement this and run it for 1024 shots.
 */
import qiskit
import Cocoa
import PlaygroundSupport
import XCPlayground

var testurl = "https://quantumexperience.ng.bluemix.net/api/"
var apitoken = "None"

do {
    let qp = try QuantumProgram()
    qp.set_api(token: apitoken, url: testurl)

    // set up registers and program
    let qr = try qp.create_quantum_register("qr", 16)
    let cr = try qp.create_classical_register("cr", 16)

    let circuit_name = "smiley_writer"
    let qc = try qp.create_circuit(circuit_name, [qr], [cr])

    // rightmost eight (qu)bits have ')' = 00101001
    try qc.x(qr[0])
    try qc.x(qr[3])
    try qc.x(qr[5])

    // second eight (qu)bits have superposition of
    // '8' = 00111000
    // ';' = 00111011
    // these differ only on the rightmost two bits
    try qc.h(qr[9]) // create superposition on 9
    try qc.cx(qr[9],qr[8]) // spread it to 8 with a cnot
    try qc.x(qr[11])
    try qc.x(qr[12])
    try qc.x(qr[13])

    // the current version of the QISKit compiler assumes that all backends
    // support re-using a qubit after measurement. Until a fix is ready for
    // this, it is neccessary to put a barrier before the measurements to
    // prevent the compiler from moving them to earlier in the circuit and
    // potentially trying to reuse qubits after measurement
    try qc.barrier(qr)

    // measure
    for j in 0..<16 {
        try qc.measure(qr[j], cr[j])
    }

    // extract qasm
    print("Print qasm for circuit \(circuit_name)\n")
    print(qc.qasm())

    // run and get results
    let backend = "ibmqx5"
    let shots = 1024
    qp.execute([circuit_name], backend: backend, shots: shots) { (result) in
        if let error = result.get_error() {
            print(error)

            return
        }

        var stats: [String : Int] = [:]
        do {
            stats = try result.get_counts(circuit_name)
        } catch {
            print(error)
        }
/*:
The results in stats tell us how many times each bit string was found as a result. To make our emoticon, we convert the bit strings into ASCII characters. We also calculate the fraction of shots for which each result occurred. The most common results are then printed to screen.

This gives us a list of characters and probabilities. But that isn't very fun. For something more visual, we use Cocoa Text Fields to create an image in which all the characters included in the result are printed on top of each other. The alpha channel of each character is set to the fraction of shots for which that result occurred. Given that we are using the simulator, this is equally split between 8) and ;), but in a real device (like _ibmqx5_) noise would mean some other stuff would turn up too.

Remember to presen the liveView: View > Assistant Editor > Show Assistant Editor
*/
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 220, height: 250))

        print("Measured bits - Corresponding emoticon : Count\n")
        for (bitstring, count) in stats {
            let index = String.Index(encodedOffset: 8)
            let leftChar = String(bitSubstring: bitstring[bitstring.startIndex..<index])
            let rightChar = String(bitSubstring: bitstring[index..<bitstring.endIndex])

            let icon = String(leftChar) + String(rightChar)
            print("\(bitstring) - '\(icon)' : \(count)")

            let alphaValue = CGFloat(count) / CGFloat(shots)
            container.addTextField(stringValue: icon, alphaValue: alphaValue)
        }

        print("\nActivate Palyground Live View to see the result")
        PlaygroundPage.current.liveView = container
/*:
And there you have it. A quantum smiley!
*/
    }
} catch {
    print(error)
}

PlaygroundPage.current.needsIndefiniteExecution = true
