//
//  Queue.swift
//  qiskit
//
//  Created by Manoel Marques on 6/2/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

struct Queue<Element> {
    private var items = [Element]()

    var isEmpty: Bool {
        return self.items.isEmpty
    }
    mutating func enqueue(_ item: Element) {
        items.append(item)
    }
    mutating func dequeue() -> Element {
        return items.removeFirst()
    }
}
