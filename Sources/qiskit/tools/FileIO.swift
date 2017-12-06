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
 Utilities for File Input/Output.
 */
public final class FileIO {

    private init() {
    }

    /**
     Combs recursively through a dictionary and finds any non-json compatible
     elements and converts them. E.g. complex ndarray's are converted to lists of strings.
     Assume that all such elements are stored in dictionaries!

     Arg:
        in_item: the input dict
     */
    public static func convert_qobj_to_json(_ in_item: [String:Any]) -> [String:Any] {
        var jsonDict: [String:Any] = [:]
        for (key, value) in in_item {
            if let valueDict = value as? [String:Any] {
                jsonDict[key] = convert_qobj_to_json(valueDict)
                continue
            }
            if let complexMatrix = value as? Matrix<Complex> {
                jsonDict["\(key)_ndarray_real"] = complexMatrix.real().value
                jsonDict["\(key)_ndarray_imag"] = complexMatrix.imag().value
                continue
            }
            if let complexVector = value as? Vector<Complex> {
                jsonDict["\(key)_ndarray_real"] = complexVector.real().value
                jsonDict["\(key)_ndarray_imag"] = complexVector.imag().value
                continue
            }
            if let complexList = value as? [Complex] {
                let complexVector = Vector<Complex>(value: complexList)
                jsonDict["\(key)_ndarray_real"] = complexVector.real().value
                jsonDict["\(key)_ndarray_imag"] = complexVector.imag().value
                continue
            }
            if let valueList = value as? [Any] {
                jsonDict[key] = convert_qobj_to_json(valueList)
                continue
            }
            jsonDict[key] = value
        }
        return jsonDict
    }

    public static func convert_qobj_to_json(_ in_item: [Any]) -> [Any] {
        var jsonList: [Any] = []
        for value in in_item {
            if let valueDict = value as? [String:Any] {
                jsonList.append(convert_qobj_to_json(valueDict))
                continue
            }
            if let valueList = value as? [Any] {
                jsonList.append(convert_qobj_to_json(valueList))
                continue
            }
            jsonList.append(value)
        }
        return jsonList
    }

    /**
     Combs recursively through a dictionary that was loaded from json
     and finds any lists that were converted from ndarray and converts them back

     Arg:
        in_item: the input dict
     */
    public static func convert_json_to_qobj(_ in_item: [String:Any]) throws -> [String:Any] {
        var qobj: [String:Any] = [:]
        var complexDict: [String: ([Any],[Any])] = [:]
        for (key, value) in in_item {
            if key.hasSuffix("_ndarray_real") {
                if let anyList = value as? [Any] {
                    let newKey = key.replacingOccurrences(of: "_ndarray_real", with: "")
                    var tuple: ([Any],[Any]) = ([],[])
                    if let t = complexDict[newKey] {
                        tuple = t
                    }
                    tuple.0 = anyList
                    complexDict[newKey] = tuple
                    continue
                }
            }
            if key.hasSuffix("_ndarray_imag") {
                if let anyList = value as? [Any] {
                    let newKey = key.replacingOccurrences(of: "_ndarray_imag", with: "")
                    var tuple: ([Any],[Any]) = ([],[])
                    if let t = complexDict[newKey] {
                        tuple = t
                    }
                    tuple.1 = anyList
                    complexDict[newKey] = tuple
                    continue
                }
            }
            if let valueDict = value as? [String:Any] {
                qobj[key] = try convert_json_to_qobj(valueDict)
                continue
            }
            if let valueList = value as? [Any] {
                qobj[key] = try convert_json_to_qobj(valueList)
                continue
            }
            qobj[key] = value
        }
        for (key, tuple) in complexDict {
            if let real = tuple.0 as? [Double],
                let imag = tuple.1 as? [Double] {
                let vector = try Vector<Complex>(real: real, imag: imag)
                qobj[key] = vector.value
                continue
            }
            if let real = tuple.0 as? [[Double]],
                let imag = tuple.1 as? [[Double]] {
                qobj[key] = try Matrix<Complex>(real: Matrix<Double>(value: real),
                                                imag: Matrix<Double>(value: imag))
            }
        }
        return qobj
    }

    public static func convert_json_to_qobj(_ in_item: [Any]) throws -> [Any] {
        var qobjList: [Any] = []
        for value in in_item {
            if let valueDict = value as? [String:Any] {
                qobjList.append(try convert_json_to_qobj(valueDict))
                continue
            }
            if let valueList = value as? [Any] {
                qobjList.append(try convert_json_to_qobj(valueList))
                continue
            }
            qobjList.append(value)
        }
        return qobjList
    }

    /**
     Constructs a filename using the current date-time

     Args:
        folder (str): path to the save folder
        fileroot (str): root string for the file

     Returns:
        String: full file path of the form 'folder/YYYY_MM_DD_HH_MM_fileroot.json'
     */
    public static func file_datestr(_ folder: String, _ fileroot: String) -> String {
        // if the fileroot has .json appended strip it off
        var root = fileroot
        if root.count > 4 && root.suffix(5).lowercased() == ".json" {
            root = String(root.dropLast(5))
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_hh_mm_"
        let name = "\(dateFormatter.string(from: Date()))\(root).json"
        return URL(fileURLWithPath: root).appendingPathComponent(name).path
    }

    /**
     Load a results dictionary file (.json) to a Result object.
     Note: The json file may not load properly if it was saved with a previous
     version of the SDK.

     Args:
        filename (str): filename of the dictionary

     Returns:
        Result: The new Results object
        Dict: if the metadata exists it will get returned
     */
    public static func load_result_from_file(_ filename: String) throws -> (Result,[String:Any]) {
        do {
            let url = URL(fileURLWithPath: filename)
            if !FileManager.default.fileExists(atPath: url.path) {
                throw QISKitError.invalidFile(file: filename)
            }
            let data = try Data(contentsOf: url)
            guard let master_dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
                throw QISKitError.invalidFile(file: filename)
            }
            guard let qobj = master_dict["qobj"] as? [String:Any] else {
                throw QISKitError.invalidFile(file: filename)
            }
            guard var qresult_dict = master_dict["result"] as? [String:Any] else {
                throw QISKitError.invalidFile(file: filename)
            }
            qresult_dict = try convert_json_to_qobj(qresult_dict)
            guard let metadata = master_dict["metadata"] as? [String:Any] else {
                throw QISKitError.invalidFile(file: filename)
            }
            return (Result(qresult_dict, qobj), metadata)
        } catch let error as QISKitError {
            throw error
        } catch {
            throw QISKitError.internalError(error: error)
        }
    }

    /**
     Save a result (qobj + result) and optional metatdata
     to a single dictionary file.

     Args:
        resultobj (Result): Result to save
        filename (str): save path (with or without the json extension). If the file already
        exists then numbers will be appended to the root to generate a unique filename.
        E.g. if filename=test.json and that file exists then the file will be changed
        to test_1.json
        metadata (dict): Add another dictionary with custom data for the result (eg fit results)

     Return:
        String: full file path
     */
    public static func save_result_to_file(_ resultobj: Result,
                                           _ file: String,
                                           metadata: [String:Any]? = nil) throws -> String {
        do {
            var master_dict: [String: Any] = [:]
            master_dict["qobj"] = resultobj._qobj
            //need to convert any ndarray variables to lists so that they can be
            //exported to the json file
            master_dict["result"] = convert_qobj_to_json(resultobj._result)
            if let m = metadata {
                master_dict["metadata"] = m
            }
            else {
                master_dict["metadata"] = [:]
            }

            let data = try JSONSerialization.data(withJSONObject: master_dict, options: .prettyPrinted)

            //if the filename has .json appended strip it off
            var filename = file
            if filename.count > 4 && filename.suffix(5).lowercased() == ".json" {
                filename = String(filename.dropLast(5))
            }

            var append_str = ""
            var append_num = 0
            var url = URL(fileURLWithPath: filename).appendingPathExtension("json")
            while FileManager.default.fileExists(atPath: url.path) {
                append_num += 1
                append_str = "\(append_str)_\(append_num)"
                url = URL(fileURLWithPath: "\(filename)\(append_str)").appendingPathExtension("json")
            }
            try data.write(to: url)
            return url.path
        } catch let error as QISKitError {
            throw error
        } catch {
            throw QISKitError.internalError(error: error)
        }
    }
}
