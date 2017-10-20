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

final class QasmCppSimulator: BaseBackend {

    public required init(_ configuration: [String:Any]?) {
        super.init(configuration)
        if let conf = configuration {
            self._configuration = conf
        }
        else {
            self._configuration = ["name": "local_qasm_cpp_simulator",
                "url": "https://github.com/IBM/qiskit-sdk-swift",
                "exe": "qasm_simulator",
                "simulator": true,
                "local": true,
                "description": "A c++ simulator for qasm files",
                "coupling_map": "all-to-all",
                "basis_gates": "u1,u2,u3,cx,id"
            ]
        }
    }

    /**
     Run simulation on C++ simulator.
     */
    override public func run(_ q_job: QuantumJob, response: @escaping ((_:Result) -> Void)) {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                let job_id = UUID().uuidString
                response(Result(["job_id": job_id, "status": "ERROR","result": SimulatorError.notImplemented(backend: self.configuration["name"] as! String).localizedDescription],q_job.qobj))
            }
        }
    }
}
