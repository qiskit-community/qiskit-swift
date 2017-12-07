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

import XCTest
@testable import qiskit

class IBMQuantumExperienceTests: XCTestCase {

    static let allTests = [
        ("test_api_auth_token",test_api_auth_token),
        ("test_api_get_my_credits",test_api_get_my_credits),
     /* ("test_api_auth_token_fail",test_api_auth_token_fail),
        ("test_api_last_codes",test_api_last_codes),
        ("test_api_run_experiment",test_api_run_experiment),
        ("test_api_run_experiment_with_seed",test_api_run_experiment_with_seed),
        ("test_api_run_experiment_fail_backend",test_api_run_experiment_fail_backend),
        ("test_api_run_job",test_api_run_job),
        ("test_api_run_job_fail_backend",test_api_run_job_fail_backend),
        ("test_api_get_jobs",test_api_get_jobs),
        ("test_api_backend_status",test_api_backend_status),
        ("test_api_backend_calibration",test_api_backend_calibration),
        ("test_api_backend_parameters",test_api_backend_parameters),
        ("test_api_backends_availables",test_api_backends_availables),
        ("test_api_backend_simulators_available",test_api_backend_simulators_available),
        ("test_register_size_limit_exception",test_register_size_limit_exception),
        ("test_qx_api_version",test_qx_api_version)*/
    ]

    private var QE_TOKEN: String? = nil
    private var QE_URL = Qconfig.BASEURL
    private var _api: IBMQuantumExperience? = nil
    private var qasm: String = ""
    private var qasms: [[String:String]] = []

    override func setUp() {
        super.setUp()
        let environment = ProcessInfo.processInfo.environment
        if let token = environment["QE_TOKEN"] {
            self.QE_TOKEN = token
        }
        if let url = environment["QE_URL"] {
            self.QE_URL = url
        }
        self.qasm = """
IBMQASM 2.0;
include "qelib1.inc";
qreg q[5];
creg c[5];
u2(-4*pi/3,2*pi) q[0];
u2(-3*pi/2,2*pi) q[0];
u3(-pi,0,-pi) q[0];
u3(-pi,0,-pi/2) q[0];
u2(pi,-pi/2) q[0];
u3(-pi,0,-pi/2) q[0];
measure q -> c;
"""
        self.qasms = [ ["qasm": qasm],
                     ["qasm": """
IBMQASM 2.0;

include "qelib1.inc";
qreg q[5];
creg c[3];
creg f[2];
x q[0];
measure q[0] -> c[0];
measure q[2] -> f[0];
"""]]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    private func getAPI() throws -> IBMQuantumExperience? {
        if let api = self._api {
            return api
        }
        guard let token = self.QE_TOKEN else {
            return nil
        }
        self._api = try IBMQuantumExperience(token, Qconfig(url: self.QE_URL))
        return self._api
    }

    func test_api_auth_token() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
            let credential = api.check_credentials()
            XCTAssert(credential)
        } catch {
            XCTFail("test_api_auth_token: \(error)")
        }
    }

    func test_api_get_my_credits() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
            let asyncExpectation = self.expectation(description: "test_api_get_my_credits")
            api.get_my_credits() { (my_credits,error) in 
                if error != nil {
                    XCTFail("Failure in test_api_get_my_credits: \(error!)")
                    asyncExpectation.fulfill()
                    return
                }
                var check_credits: Int? = nil
                if let c = my_credits["remaining"] as? Int {
                    check_credits = c
                    SDKLogger.logInfo("\(c)")
                }
                XCTAssertNotNil(check_credits)
                asyncExpectation.fulfill()
            }
            self.waitForExpectations(timeout: 180, handler: { (error) in
                XCTAssertNil(error, "Failure in test_api_get_my_credits")
            })
        } catch {
            XCTFail("test_api_get_my_credits: \(error)")
        }
    }
/*
    func test_api_auth_token_fail() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
            self.assertRaises(ApiError,IBMQuantumExperience, "fail")
        } catch {
            XCTFail("test_api_auth_token_fail: \(error)")
        }
    }

    func test_api_last_codes() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
            self.assertIsNotNone(api.get_last_codes())
        } catch {
            XCTFail("test_api_last_codes: \(error)")
        }
    }

    func test_api_run_experiment() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
            let backend = api.available_backend_simulators()[0]["name"]
            let shots = 1
            experiment = api.run_experiment(self.qasm, backend, shots)
            check_status = None
            if "status" in experiment {
                check_status = experiment["status"]
            }
            self.assertIsNotNone(check_status)
        } catch {
            XCTFail("test_api_run_experiment: \(error)")
        }
    }

    func test_api_run_experiment_with_seed() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backend = api.available_backend_simulators()[0]["name"]
        shots = 1
        seed = 815
        experiment = api.run_experiment(self.qasm, backend, shots,
        seed=seed)
        check_seed = -1
        if ("result" in experiment) and \
        ("extraInfo" in experiment["result"]) and \
        ("seed" in experiment["result"]["extraInfo"]):
        check_seed = int(experiment["result"]["extraInfo"]["seed"])
        self.assertEqual(check_seed, seed)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_run_experiment_fail_backend() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backend = "5qreal"
        shots = 1
        self.assertRaises(BadBackendError,
        api.run_experiment, self.qasm, backend, shots)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_run_job() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backend = "simulator"
        shots = 1
        job = api.run_job(self.qasms, backend, shots)
        check_status = None
        if "status" in job:
        check_status = job["status"]
        self.assertIsNotNone(check_status)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_run_job_fail_backend() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backend = "real5"
        shots = 1
        self.assertRaises(BadBackendError, api.run_job, self.qasms,
        backend, shots)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }
    func test_api_get_jobs() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        jobs = api.get_jobs(2)
        self.assertEqual(len(jobs), 2)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_backend_status() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        is_available = api.backend_status()
        self.assertIsNotNone(is_available["available"])
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_backend_calibration() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        calibration = api.backend_calibration()
        self.assertIsNotNone(calibration)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_backend_parameters() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        parameters = api.backend_parameters()
        self.assertIsNotNone(parameters)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_api_backends_availables() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backends = api.available_backends()
        self.assertGreaterEqual(len(backends), 2)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }
    func test_api_backend_simulators_available() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backends = api.available_backend_simulators()
        self.assertGreaterEqual(len(backends), 1)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_register_size_limit_exception() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        backend = "simulator"
        shots = 1
        qasm = """
OPENQASM 2.0;
include "qelib1.inc";
qreg q[25];
creg c[25];
h q[0];
h q[24];
measure q[0] -> c[0];
measure q[24] -> c[24];
        """
        self.assertRaises(RegisterSizeError, api.run_job,
        [{"qasm": qasm}], backend, shots)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }

    func test_qx_api_version() {
        do {
            guard let api = try self.getAPI() else {
                return
            }
        version = api.api_version()
        self.assertGreaterEqual(int(version.split(".")[0]), 4)
} catch {
    XCTFail("test_api_auth_token: \(error)")
}
    }*/
}
