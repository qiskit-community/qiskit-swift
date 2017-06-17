//
//  SyncLock.swift
//  qiskit
//
//  Created by Manoel Marques on 6/17/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

final class SyncLock {

    class func synchronized(_ lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    private init() {

    }
}
