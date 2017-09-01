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

/**
 Result Class.
 Class internal properties.
 Methods to process the quantum program after it has been run
 Internal::
     qobj =  { -- the quantum object that was complied --}
     result =
         [
             {
             "data":
                 {  #### DATA CAN BE A DIFFERENT DICTIONARY FOR EACH BACKEND ####
                 "counts": {’00000’: XXXX, ’00001’: XXXXX},
                 "time"  : xx.xxxxxxxx
                 },
             "status": --status (string)--
             },
             ...
        ]
 */
public final class Result: CustomStringConvertible {

    private let __qobj: [String:Any]
    private let __result: [String:Any]

    init() {
        self.__qobj = [:]
        self.__result = [:]
    }

    init(_ qobj_result: [String:Any], _ qobj: [String:Any]) {
        self.__qobj = qobj
        self.__result = qobj_result
    }

    /**
     Get the status of the run.
     Returns:
     the status of the results.
     */
    public var description: String {
        do {
            return try self.status()
        }
        catch {
            return ""
        }
    }

    /**
     Get the status of the run.
     Returns:
     the status of the results.
     */
    public func status() throws -> String {
        guard let status = self.__result["status"] as? String else {
            throw QISKitError.missingStatus
        }
        return status
    }

    public func get_error() throws -> [String:Any]? {
        let status = try self.status()
        if status == "ERROR" {
            if let results = self.__result["result"] as? [[String:Any]] {
                return results[0]
            }
        }
        return nil
    }

    /**
     Get the ran qasm for the named circuit and backend.
     Args:
     name (str): the name of the quantum circuit.
     Returns:
     A text version of the qasm file that has been run
     */
    public func get_ran_qasm(_ name: String) throws -> String {
        let qobj = self.__qobj
        if let circuits = qobj["circuits"] as? [[String:Any]] {
            for circuit in circuits {
                if let n = circuit["name"] as? String {
                    if n == name {
                        if let ret = circuit["compiled_circuit_qasm"] as? String {
                            return ret
                        }
                    }
                }
            }
        }
        throw QISKitError.noQASM(name: name)
    }

    /**
     "Get the data of cicuit name.
     The data format will depend on the backend. For a real device it
     will be for the form::
     "counts": {’00000’: XXXX, ’00001’: XXXX},
     "time"  : xx.xxxxxxxx
     for the qasm simulators of 1 shot::
     'quantum_state': array([ XXX,  ..., XXX]),
     'classical_state': 0
     for the qasm simulators of n shots::
     'counts': {'0000': XXXX, '1001': XXXX}
     for the unitary simulators::
     'unitary': np.array([[ XX + XXj
     ...
     XX + XX]
     ...
     [ XX + XXj
     ...
     XX + XXj]]
     Args:
     name (str): the name of the quantum circuit.
     Returns:
     A dictionary of data for the different backends
     */
    public func get_data(_ name: String) throws -> [String:Any] {
        let qobj = self.__qobj
        if let circuits = qobj["circuits"] as? [[String:Any]], 
            let results = self.__result["result"] as? [[String:Any]] {
            for (index, circuit) in circuits.enumerated() {
                if let n = circuit["name"] as? String {
                    if n == name {
                        if let data = results[index]["data"] as? [String:Any] {
                            return data
                        }
                    }
                }
            }
        }
        throw QISKitError.noData(name: name)
    }

    /**
     Get the histogram data of cicuit name.
     The data from the a qasm circuit is dictionary of the format
     {’00000’: XXXX, ’00001’: XXXXX}.
     Args:
     name (str): the name of the quantum circuit.
     backend (str): the name of the backend the data was run on.
     Returns:
     A dictionary of counts {’00000’: XXXX, ’00001’: XXXXX}.
     */
    public func get_counts(_ name: String) throws -> [String:Int] {
        if let counts = try self.get_data(name)["counts"] as? [String:Int] {
            return counts
        }
        throw QISKitError.noCounts(name: name)
    }

    /**
     Compute the mean value of an diagonal observable.
     Takes in an observable in dictionary format and then
     calculates the sum_i value(i) P(i) where value(i) is the value of
     the observable for state i.
     Args:
     name (str): the name of the quantum circuit
     observable (dict): The observable to be averaged over. As an example
     ZZ on qubits equals {"00": 1, "11": 1, "01": -1, "10": -1}
     Returns:
     a double for the average of the observable
     */
    public func average_data(_ name: String, _ observable: [String:Int]) throws -> Double {
        let counts = try self.get_counts(name)
        var tot: Double = 0
        for (_,countValue) in counts {
            tot += Double(countValue)
        }
        var temp: Double = 0
        for (key,countValue) in counts {
            if let value = observable[key] {
                temp += Double(countValue) * Double(value) / tot
            }
        }
        return temp
    }
}
