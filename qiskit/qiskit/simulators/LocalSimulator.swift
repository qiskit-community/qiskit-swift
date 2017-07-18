//
//  LocalSimulator.swift
//  qiskit
//
//  Created by Manoel Marques on 7/14/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

/**
 Interface to local simulators.

 This module is the interface to all the local simulators in this directory.
 It handles automatically discovering and interfacing with those modules. Once
 instantiated like::

 >>> import _localsimulator
 >>> simulator_list = _localsimulator.local_backends()
 >>> sim = _localsimulator.LocalSimulator(simulator_list[0], job)
 >>> sim.run()
 >>> results = sim.results()

 `simulator_list` is the list of names of known simulators and `job` is
 a dictionary of the form {'compiled_circuit': circuit, 'shots': shots,
 'seed': seed}.

 The import does discovery of the simulator modules in this directory. The
 second command attempts to determine which modules are functional, in
 particular for modules which require making calls to compiled binaries.

 In order for a module to be registered in needs to define module-scope
 dictionary of the form::

 __configuration ={"name": "local_qasm_simulator",
 "url": "https://github.com/IBM/qiskit-sdk-py",
 "simulator": True,
 "description": "A python simulator for qasm files",
 "nQubits": 10,
 "couplingMap": "all-to-all",
 "gateset": "SU2+CNOT"}

 and it needs a class with a run method. The identifier for the backend
 simulator comes from the "name" key in this dictionary. The class'
 __init__ method is called with a single `job` argument. The __init__
 method is also responsible for determining whether an associated
 binary is available. If it is not, the FileNotFoundError exception
 should be raised.

 Attributes
 ----------
 local_configuration : list of dict()
 This list gets populated with the __configuration records from each
 of the discovered modules.

 _simulator_classes : dict {"<simulator name>" : <simulator class>}
 This dictionary associates a simulator name with the class which
 generates its objects.
 */
final class LocalSimulator {

    static var local_configurations: [[String:Any]] {
        return [QasmCppSimulator.__configuration,
                QasmSimulator.__configuration,
                UnitarySimulator.__configuration]
    }

    static var local_backends: [String] {
        var backends: [String] = []
        for configuration in local_configurations {
            if let name = configuration["name"] as? String {
                backends.append(name)
            }
        }
        return backends
    }

    static private func sim(_ name: String, _ job: [String:Any]) throws -> Simulator {
        if name == (QasmCppSimulator.__configuration["name"] as? String) {
            return QasmCppSimulator(job)
        }
        if name == (QasmSimulator.__configuration["name"] as? String) {
            return QasmSimulator(job)
        }
        if name == (UnitarySimulator.__configuration["name"] as? String) {
            return UnitarySimulator(job)
        }
        throw SimulatorError.unknownSimulator(name: name)
    }

    private let backend: String
    private let job: [String:Any]
    private let _sim: Simulator
    private var _result: [String:Any] = [:]

    var result: [String:Any] {
        return self._result
    }

    init(_ backend: String, _ job: [String:Any]) throws {
        self.backend = backend
        self.job = job
        self._sim = try LocalSimulator.sim(self.backend,self.job)
    }

    func run() throws {
        let simOutput = try self._sim.run()
        self._result["result"] = []
        if let data = simOutput["data"] {
            self._result["result"] = ["data" : data]
        }
        if let status = simOutput["status"] {
            self._result["status"] = status
        }
    }
}
