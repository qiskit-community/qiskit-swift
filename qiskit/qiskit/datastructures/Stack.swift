//
//  Stack.swift
//  qiskit
//
//  Created by Manoel Marques on 5/25/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

struct Stack<Element> {
    private var items = [Element]()

    var isEmpty: Bool {
        return self.items.isEmpty
    }
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}
