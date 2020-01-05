//
//  Queue.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 10/1/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import Foundation

class Queue<T> {
    var list: [T] = []

    func enqueue(item: T) {
        list.append(item)
    }

    func dequeue() -> T? {
        if isEmpty {
            return nil
        }

        return list.removeFirst()
    }

    func clean() {
        list.removeAll()
    }

    var count: Int {
        return list.count
    }

    var isEmpty: Bool {
        return list.isEmpty
    }
}
