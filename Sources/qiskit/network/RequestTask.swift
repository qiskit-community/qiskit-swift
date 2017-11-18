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
 Single or group os Asynchronous tasks
 */
public final class RequestTask {

    private let task: URLSessionDataTask?
    private var children: [RequestTask] = []
    private var cancelled = false
    private let lock = NSRecursiveLock()

    public init() {
        self.task = nil
    }

    init(_ task: URLSessionDataTask) {
        self.task = task
    }

    /**
     Adds a task as child
     */
    public func add(_ requestTask: RequestTask) {
        self.lock.lock()
        self.children.append(requestTask)
        if self.cancelled {
            requestTask.cancel()
        }
        self.lock.unlock()
    }

    /**
     Checkes is is a task has been cancelled
     */
    public func isCancelled() -> Bool {
        self.lock.lock()
        let ret = self.cancelled
        self.lock.unlock()
        return ret
    }
    /**
     Cancels a task and all its children
     */
    public func cancel() {
        self.lock.lock()
        if !self.cancelled {
            if let t = self.task {
                t.cancel()
            }
            for requestTask in self.children {
                requestTask.cancel()
            }
            self.cancelled = true
        }
        self.lock.unlock()
    }

    public static func + (left: RequestTask, right: RequestTask) -> RequestTask {
        let ret =  RequestTask()
        ret.add(left)
        ret.add(right)
        return ret
    }

    public static func += (left: inout RequestTask, right: RequestTask) {
        left.add(right)
    }
}
