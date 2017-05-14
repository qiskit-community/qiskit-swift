import Cocoa
import qiskit
import PlaygroundSupport
import XCPlayground

/*:
## Swift API Client IBM Quantum Experience
The Official API Client to use **IBM Quantum Experience in Swift**.
 
### This package can be use in Swift Playground.

[Installation]: https://github.com/IBM/qiskit-api-py#installation "python place holder"
[Getting Started]:  https://github.com/IBM/qiskit-api-py#getting-started "python place holder"
[Classes and Methods]:  https://github.com/IBM/qiskit-api-py#methods "python place holder"
[Reference]: https://github.com/IBM/qiskit-api-py#reference "python place holder"

- To begin install the Swift Quantum SDK [Installation].
- Then proceed to getting started writing your quantum circuits using the Swift programming language [Getting Started].
- Classes and Methods are defined as follows: [Classes and Methods].
- Reference material can be found here: [Reference].

 ![Playground icon](IBM5Q.png)

*/

/*:
## Writing a Quantum Circuit in the Swift Programming Language
The Swift Quantum SDK provides data types for creating your quantum code.
Here we provide additional information about Swift and Quantum computing
that will help you become a great quantum circuit designer and solve very complex
problems that exceed the limits of classical computing. If you study quantum computing
you may find many interesting problems to solve.
*/
var testurl = "https://quantumexperience.ng.bluemix.net/api/"
var apitoken = "your api token here"


let q = Qqreg("q", 1)
let c = Qcreg("c", 1)

let qasm = QASM()
    .append(QComment("Simple 1 qubit test"))
    .append(QInclude("qelib1.inc"))
    .append(q)
    .append(c)
    .append(QMeasure(q[0], c[0]))

do {
    let config = try Qconfig(apiToken: apitoken, url: testurl)
    let api = IBMQuantumExperience(config: config)
    api.runJobToCompletion(qasms: [qasm.description], device: IBMQuantumExperience.Device.simulator,
                           shots: 1024, maxCredits: 3) { (result, error) in
        if let jobResult = result {
            
            if let qasms = jobResult.qasms {
                
                let qasm = qasms[0]
                let idExecution = qasm.executionId!
                api.getExecution(idExecution) { (execution, error) in
                    if error == nil {
                        api.getResultFromExecution(idExecution) { (result, error) in
                            if let resultData = result?.data?.dataP?.json {
                               
                                let histogramView = HistogramView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
                                histogramView.showResultsByExecution(results: resultData)
                                
                                
                                let blochModel = BlochModelView(frame: NSRect(x: 0, y: 0, width: 640, height: 480))
                                blochModel.setupBlochSphereScene()
                                blochModel.hideWaiting()
                                blochModel.showResultsByExecution(results: resultData)
                                PlaygroundPage.current.liveView = blochModel
                            }
                        }
                    }
                }
            }
            
        }
    }
} catch let error {
    print(error.localizedDescription)
}


PlaygroundPage.current.needsIndefiniteExecution = true
