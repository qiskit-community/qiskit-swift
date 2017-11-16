Quantum Information Software Kit (QISKit)
=========================================

Swift software development kit (SDK) for working
with OpenQASM and the IBM Q experience (QX).

Philosophy
----------

The basic concept of our quantum program is an array of quantum
circuits. The program workflow consists of three stages: Build, Compile,
and Run. Build allows you to make different quantum circuits that
represent the problem you are solving; Compile allows you to rewrite
them to run on different backends (simulators/real chips of different
quantum volumes, sizes, fidelity, etc); and Run launches the jobs. After
the jobs have been run, the data is collected. There are methods for
putting this data together, depending on the program. This either gives
you the answer you wanted or allows you to make a better program for the
next instance.

Organization
------------

Swift example programs can be found in the *examples* directory, and test scripts are
located in *test*. The *qiskit* directory is the main module of the SDK.

Structure
---------

Programming interface
~~~~~~~~~~~~~~~~~~~~~

The *qiskit* directory is the main Swift Framework and contains the
programming interface objects *QuantumProgram*, *QuantumRegister*,
*ClassicalRegister*, and *QuantumCircuit*.

At the highest level, users construct a *QuantumProgram* to create,
modify, compile, and execute a collection of quantum circuits. Each
*QuantumCircuit* has a set of data registers, each of type
*QuantumRegister* or *ClassicalRegister*. Methods of these objects are
used to apply instructions that define the circuit. The *QuantumCircuit*
can then generate **OpenQASM** code that can flow through other
components in the *qiskit* directory.

The *extensions* directory extends quantum circuits as needed to support
other gate sets and algorithms. Currently there is a *standard*
extension defining some typical quantum gates.

Internal modules
~~~~~~~~~~~~~~~~

The directory also contains internal modules that are still under
development:

-  a *qasm* module for parsing **OpenQASM** circuits
-  an *unroll* module to interpret and "unroll" **OpenQASM** to a target
gate basis (expanding gate subroutines and loops as needed)
-  a *circuit* module for working with circuits as graphs
-  a *mapper* module for mapping all-to-all circuits to run on devices
with fixed couplings

Quantum circuits flow through the components as follows. The programming
interface is used to generate **OpenQASM** circuits. **OpenQASM**
source, as a file or string, is passed into a *Qasm* object, whose
*parse* method produces an abstract syntax tree (**AST**). The **AST**
is passed to an *Unroller* that is attached to an *UnrollerBackend*.
There is a *PrinterBackend* for outputting text, a *JsonBackend*
for outputting JSON data, a *CircuitBackend* for constructing *QuantumCircuit* objects
and a DAGBackend for constructing *DAGCircuit* objects. The *DAGCircuit*
object represents an "unrolled" **OpenQASM** circuit as a directed
acyclic graph (**DAG**). The *DAGCircuit* provides methods for
representing, transforming, and computing properties of a circuit and
outputting the results again as **OpenQASM**. The whole flow is used by
the *mapper* module to rewrite a circuit to execute on a device with
fixed couplings given by a *CouplingGraph*.

The four circuit representations and how they are currently transformed
into each other are summarized in this figure:

.. image:: images/circuit_representations.png
    :width: 200px
    :align: center

Installation and setup
----------------------

1. Get the tools
~~~~~~~~~~~~~~~~

You'll need:

-  Install `Xcode <https://developer.apple.com/xcode/>`__.
-  Install `Carthage <https://github.com/Carthage/Carthage>`__.

2. Get the code
~~~~~~~~~~~~~~~

Clone the QISKit SDK repository and navigate to its folder on your local
machine:

-  If you have Git installed, run the following commands:

.. code:: sh

    git clone https://github.com/QISKit/qiskit-sdk-swift
    cd qiskit-sdk-swift

-  If you don't have Git installed, click the "Clone or download" button at the URL shown in the git clone command, unzip the file if needed, then navigate to that folder in a terminal window.

3. Alternatively install using Carthage
~~~~~~~~~~~~~~~~~~~~~~~~

- Install using Carthage: https://github.com/Carthage/Carthage
- Run carthage update

4. Configure your API token
~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Create an `IBM Quantum Experience <https://quantumexperience.ng.bluemix.net>`__ account if you haven't already done so
-  Get an API token from the Quantum Experience website under “My Account” > “Personal Access Token”
-  When developing your own project, you will pass your API token to a network object called Qconfig.swift.

5. Build and run the Swift Playground Tutorial 
~~~~~~~~~~~~~~~~~~~~~~~~~~~
- Run carthage update to pull the latest Swift qiskit:
- Open the QisSwiftPlayground.xcodeproj
- Compile the qiskit framework
- Add your API token to the file "QisSwiftDeveloperTutorial.playground"
- Swift Playgrounds run automatically

5. Using Swift Package Manager (OSX and Ubuntu)
~~~~~~~~~~~~~~~~~~~~~~~~~~~
- For Ubuntu download and install the latest Swift runtime from https://swift.org/download/
- From the top folder, run "swift build" or "swift test" to run the Unit tests
- Once "swift build" is run, you can try the command line examples from .build/debug/qiskitexamples program. If you run without options, it will show correct usage.


Authors (alphabetical)
----------------------

Jim Challenger, Andrew Cross, Ismael Faro, Jay Gambetta, Juan Gomez, Joe Ligman, Manoel Marques, Paco Martin, Antonio Mezzacapo, Jesus Perez, and John Smolin, Erick Winston, Chris Wood.

In future releases, anyone who contributes code to this project can include their name here.

Other QISKit projects
---------------------
- `Python QISKit <https://github.com/QISKit/qiskit-sdk-py.git>`
- `ibmqx backend information <https://github.com/QISKit/ibmqx-backend-information>`__ Information about the different IBM Q experience backends.
- `ibmqx user guide <https://github.com/QISKit/ibmqx-user-guides>`__ The users guides for the IBM Q experience.
- `OpenQasm <https://github.com/QISKit/openqasm>`__ Examples and tools for the OpenQASM intermediate representation.
- `Python API <https://github.com/QISKit/qiskit-api-py>`__ API Client to use IBM Q experience in Python.
- `Tutorials <https://github.com/QISKit/qiskit-tutorial>`__ Jupyter notebooks for using QISKit.


License
-------

QISKit is released under the `Apache license, version
2.0 <https://www.apache.org/licenses/LICENSE-2.0>`__.

Do you want to help?
--------------------

If you'd like to contribute please take a look to our
`contribution guidelines <CONTRIBUTING.rst>`__.

