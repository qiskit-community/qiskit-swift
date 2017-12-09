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
#if os(Linux)
import Dispatch
#endif

class RegisteredBackend {
    let name: String
    let configuration: [String:Any]

    init(_ name: String, _ configuration: [String:Any]) {
        self.name = name
        self.configuration = configuration
    }

    func newInstance() -> BaseBackend {
        preconditionFailure("newInstance not implemented")
    }
}

final class LocalRegisteredBackend :  RegisteredBackend  {
    let cls: BaseBackend.Type

    init(_ name: String, _ configuration: [String:Any], _ cls: BaseBackend.Type) {
        self.cls = cls
        super.init(name,configuration)
    }

    override func newInstance() -> BaseBackend {
        return self.cls.init(self.configuration)
    }
}

final class RemoteRegisteredBackend :  RegisteredBackend {
    let api: IBMQuantumExperience

    init(_ name: String, _ configuration: [String:Any], _ api: IBMQuantumExperience) {
        self.api = api
        super.init(name,configuration)
    }

    override func newInstance() -> BaseBackend {
        let qeRemote = QeRemote(self.configuration)
        qeRemote.api = self.api
        return qeRemote
    }
}

final class BackendUtils {

    private var _registered_backends: [String:RegisteredBackend] = [:]
    private var _api: IBMQuantumExperience?
    private var needsUpdate: Bool = true
    private let lock = NSRecursiveLock()    

    var api: IBMQuantumExperience? {
        get {
            return self._api
        }
        set(newApi) {
            self._api = newApi
            self.needsUpdate = true
        }
    }

    init() {
        self.discover_local_backends()
    }

    @discardableResult
    private func discover_local_backends() -> Set<String> {
        let backends = [//QasmCppSimulator.self,
                        QasmSimulator.self,
                        UnitarySimulator.self]
        var backend_name_list = Set<String>()
        for backend in backends {
            backend_name_list.insert(register_local_backend(backend))
        }
        return backend_name_list
    }

    private func discover_remote_backends(_ api: IBMQuantumExperience, responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return api.available_backends() { (configuration_list,error) in
            if error != nil {
                responseHandler([],error)
                return
            }
            var backend_name_list = Set<String>()
            for var configuration in configuration_list {
                configuration["local"] = false
                backend_name_list.insert(self.register_remote_backend(configuration,api))
            }
            responseHandler(backend_name_list,nil)
        }
    }

    private func update_backends(responseHandler: @escaping ((_:Set<String>, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        if !self.needsUpdate {
            var backends = self.local_backends()
            backends = backends.union(self.remote_backends())
            responseHandler(backends,nil)
            return RequestTask()
        }
        self.lock.lock()
        self._registered_backends = [:]
        self.lock.unlock()
        var backend_name_list = self.discover_local_backends()
        if self.api == nil {
            self.needsUpdate = false
            DispatchQueue.main.async {
                responseHandler(backend_name_list,nil)
            }
            return RequestTask()
        }
        return self.discover_remote_backends(self.api!) { (backends,error) in
            if error == nil {
                self.needsUpdate = false
            }
            backend_name_list = backend_name_list.union(backends)
            responseHandler(backend_name_list,error)
        }
    }

    private func register_local_backend(_ cls: BaseBackend.Type, _ configuration: [String:Any]? = nil) -> String {
        let backend_instance = cls.init(configuration)
        if let name = backend_instance.configuration["name"] as? String {
            let backend = LocalRegisteredBackend(name,backend_instance.configuration,cls)
            self.lock.lock()
            self._registered_backends[name] = backend
            self.lock.unlock()
            return name
        }
        return ""
    }

    private func register_remote_backend(_ configuration: [String:Any]? = nil, _ api: IBMQuantumExperience) -> String {
        let backend_instance = QeRemote(configuration)
        if let name = backend_instance.configuration["name"] as? String {
            let backend = RemoteRegisteredBackend(name,backend_instance.configuration,api)
            self.lock.lock()
            self._registered_backends[name] = backend
            self.lock.unlock()
            return name
        }
        return ""
    }

    func get_backend_instance(_ backend_name: String,_ responseHandler: @escaping ((_:BaseBackend?, _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return self.update_backends() { (backends,error) in
            if error != nil {
                responseHandler(nil,error)
                return
            }
            var backend: RegisteredBackend? = nil
            self.lock.lock()
            backend = self._registered_backends[backend_name]
            self.lock.unlock()
            if backend == nil {
                responseHandler(nil,IBMQuantumExperienceError.badBackendError(backend: backend_name))
                return
            }
            responseHandler(backend!.newInstance(),nil)
        }
    }

    func get_backend_configuration(_ backend_name: String,_ responseHandler: @escaping ((_:[String:Any], _:IBMQuantumExperienceError?) -> Void)) -> RequestTask {
        return self.update_backends() { (backends,error) in
            if error != nil {
                responseHandler([:],error)
                return
            }
            var backend: RegisteredBackend? = nil
            self.lock.lock()
            backend = self._registered_backends[backend_name]
            self.lock.unlock()
            if backend == nil {
                responseHandler([:],IBMQuantumExperienceError.badBackendError(backend: backend_name))
                return
            }
            responseHandler(backend!.configuration,nil)
        }
    }

    /**
     Get the local backends.
     */
    func local_backends() -> Set<String> {
        var names = Set<String>()
        self.lock.lock()
        for (_,backend) in self._registered_backends {
            if let local = backend.configuration["local"] as? Bool {
                if local {
                    names.insert(backend.name)
                }
            }
        }
        self.lock.unlock()
        return names
    }

    /**
    Get the remote backends.
     */
    private func remote_backends() -> Set<String> {
        var names = Set<String>()
        self.lock.lock()
        for (_,backend) in self._registered_backends {
            if let local = backend.configuration["local"] as? Bool {
                if !local {
                    names.insert(backend.name)
                }
            }
        }
        self.lock.unlock()
        return names
    }
}
