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

final class RegisteredBackend {
    let name: String
    let cls: BaseBackend.Type
    let configuration: [String:Any]

    init(_ name: String, _ cls: BaseBackend.Type, _ configuration: [String:Any]) {
        self.name = name
        self.cls = cls
        self.configuration = configuration
    }
}

final class BackendUtils {

    static private var _REGISTERED_BACKENDS: [String:RegisteredBackend] = [:]

    static private func discover_sdk_backends() {
        if _REGISTERED_BACKENDS.isEmpty {
            let backends = [QasmCppSimulator.self,
                            QasmSimulator.self,
                            UnitarySimulator.self]
            for backend in backends {
                register_backend(backend)
            }
        }
    }

    static private func register_backend(_ cls: BaseBackend.Type) {
        let circuit: [String:Any] = [
                        "header": ["clbit_labels": [["cr", 1]],
                                   "number_of_clbits": 1,
                                   "number_of_qubits": 1,
                                   "qubit_labels": [["qr", 0]]
                        ],
                        "operations":
                        [
                            ["name": "h",
                             "params": [],
                             "qubits": [0]
                            ],
                            ["clbits": [0],
                             "name": "measure",
                             "qubits": [0]
                            ]
                        ]
        ]
        let qobj: [String:Any] = ["id": "backend_discovery",
                    "config": [
                        "max_credits": 3,
                        "shots": 1,
                        "backend": nil,
                    ],
                    "circuits": [["compiled_circuit": circuit]]
        ]
        let backend_instance = cls.init(qobj)
        if let name = backend_instance.configuration["name"] as? String {
            _REGISTERED_BACKENDS[name] = RegisteredBackend(name,cls,backend_instance.configuration)
        }
    }

    /**
     Return the class object for the named backend.
     Args:
     backend_name (str): the backend name
     Returns:
     class object for backend_name
     Raises:
     LookupError if backend is unavailable
     */
    static func get_backend_class(_ backend_name: String) throws -> BaseBackend.Type {
        discover_sdk_backends()
        guard let backend = _REGISTERED_BACKENDS[backend_name] else {
            throw SimulatorError.notImplemented(backend: backend_name)
        }
        return backend.cls
    }

    /**
     Return the configuration for the named backend.
     Args:
         backend_name (str): the backend name
     Returns:
         configuration dict
     Raises:
         LookupError if backend is unavailable
     */
    static func get_backend_configuration(_ backend_name: String) throws -> [String:Any] {
        discover_sdk_backends()
        guard let backend = _REGISTERED_BACKENDS[backend_name] else {
            throw SimulatorError.notImplemented(backend: backend_name)
        }
        return backend.configuration
    }

    /**
     Get the local backends.
     */
    static func local_backends() -> Set<String> {
        discover_sdk_backends()
        var names = Set<String>()
        for (_,backend) in _REGISTERED_BACKENDS {
            if let local = backend.configuration["local"] as? Bool {
                if local {
                    names.insert(backend.name)
                }
            }
        }
       return names
    }

    /**
    Get the remote backends.
     */
    static func remote_backends() -> Set<String> {
        discover_sdk_backends()
        var names = Set<String>()
        for (_,backend) in _REGISTERED_BACKENDS {
            if let local = backend.configuration["local"] as? Bool {
                if !local {
                    names.insert(backend.name)
                }
            }
        }
        return names
    }
}
