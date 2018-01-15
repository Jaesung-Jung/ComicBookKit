//
//  Cache.swift
//
//  Copyright (c) 2018 Jaesung Jung.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

class Cache<K : Hashable, V> {
    private var storage: [K: V] = [:]

    let keys = KeyList<K>()
    var capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
    }

    func setValue(_ value: V, forKey key: K) {
        if capacity == keys.count {
            let first = keys.removeFirst()!
            storage.removeValue(forKey: first)
        }
        if storage[key] != nil {
            keys.moveToLast(value: key)
        } else {
            keys.append(key)
        }
        storage[key] = value
    }

    func value(forKey key: K) -> V? {
        return storage[key]
    }

    subscript(key: K) -> V? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
}

extension Cache: Collection {
    typealias Element = (K, V)
    typealias Index = Dictionary<K, V>.Index

    var startIndex: Index {
        return storage.startIndex
    }
    
    var endIndex: Index {
        return storage.endIndex
    }
    
    func index(after i: Index) -> Index {
        return storage.index(after: i)
    }

    subscript(position: Index) -> Element {
        return storage[position]
    }
}
