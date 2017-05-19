# Qiskit SDK Swift


Swift software development kit (SDK) and Swift playground for working with
OPENQASM and the IBM Quantum Experience (QE).


## Organization

The *tutorial* directory contains a Swift playground showing how to use the
[Swift API](https://github.ibm.com/IBMQuantum/qiskit-sdk-swift-dev) with
[OPENQASM](https://github.com/IBM/qiskit-openqasm).

In the *tutorial* directory are Swift playgrounds demonstrating components of
the SDK, and more Swift examples in the *examples* directory. There are also command line tests
included in the *sdk tests* directory.

Users can construct a *QuantumProgram* to create, modify, compile, and execute a collection of quantum circuits.

Each *QuantumCircuit* has some set of registers, *QuantumRegister* and *ClassicalRegister*, and methods of these objects are used to apply instructions within the circuit. The *extensions* directory extends
the quantum circuit as needed to support new gate sets and algorithms. For example, the "cswap" gate in the standard extension shows how to build gates that are sequences of
other unitary gates. 

The *qiskit* directory is the main Swift Framework and contains the programming
interface objects *QuantumProgram*, *QuantumRegister*, *ClassicalRegister*, and *QuantumCircuit*.


## Install

- Install using Carthage: https://github.com/Carthage/Carthage
- Or clone the repo: git "git@github.ibm.com:IBMQuantum/qiskit-sdk-swift-dev.git" "master"


## Use in Xcode

- Run carthage update to pull the latest Swift qiskit:
- Open the QisSwiftPlayground.xcodeproj
- Compile the qiskit framework
- Add your API token to the file "QisSwiftDeveloperTutorial.playground" (get it from [IBM Quantum Experience](https://quantumexperience.ng.bluemix.net) > Account):
- Swift Playgrounds run automatically 


## Developer Guide

Please, use [GitHub pull requests](https://help.github.com/articles/using-pull-requests) to send contributions.

