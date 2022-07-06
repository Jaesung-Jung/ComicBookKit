//
//  KeyList.swift
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

class KeyList<T: Hashable> {
  private var head: Node?
  private var tail: Node?
  private(set) var count: Int = 0
  
  func append(_ value: T) {
    let node = Node(value: value)
    if head === tail {
      if head == nil && tail == nil {
        head = node
        tail = node
      } else {
        head?.next = node
        tail = node
      }
    } else {
      tail?.next = node
      tail = node
    }
    count += 1
  }
  
  func moveToLast(value: T) {
    guard tail?.value != value else {
      return
    }
    guard head?.value != value else {
      let target = head
      head = head?.next
      tail?.next = target
      tail = target
      target?.next = nil
      return
    }
    var target = head
    repeat {
      if target?.next?.value == value {
        let node = target?.next
        target?.next = node?.next
        tail?.next = node
        tail = node
        node?.next = nil
        return
      }
      target = target?.next
    } while target?.next != nil
  }
  
  @discardableResult
  func removeFirst() -> T? {
    defer {
      count = Swift.max(count - 1, 0)
    }
    if head === tail {
      head = nil
      tail = nil
      return nil
    }
    else {
      let value = head?.value
      head = head?.next
      return value
    }
  }
  
  class Node {
    let value: T
    var next: Node?
    
    init(value: T) {
      self.value = value
    }
  }
}

extension KeyList: Sequence {
  class Iterator: IteratorProtocol {
    var target: Node?
    
    init(target: Node?) {
      self.target = target
    }
    
    func next() -> T? {
      defer {
        target = target?.next
      }
      return target?.value
    }
  }
  
  func makeIterator() -> KeyList<T>.Iterator {
    return Iterator(target: head)
  }
}
