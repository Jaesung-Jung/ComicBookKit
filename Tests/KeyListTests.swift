//
//  KeyListTests.swift
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

import XCTest
@testable import ComicBookKit

class KeyListTests: XCTestCase {
  func testKeyList() {
    let list = KeyList<Int>()
    XCTAssertTrue(list.map { $0 }.isEmpty)

    list.append(1)
    list.append(2)
    list.append(3)
    XCTAssertEqual(list.count, 3)
    XCTAssertEqual(list.map { $0 }, [1, 2, 3])

    list.removeFirst()
    XCTAssertEqual(list.count, 2)
    XCTAssertEqual(list.map { $0 }, [2, 3])

    list.moveToLast(value: 1)
    XCTAssertEqual(list.count, 2)
    XCTAssertEqual(list.map { $0 }, [2, 3])

    list.moveToLast(value: 2)
    XCTAssertEqual(list.count, 2)
    XCTAssertEqual(list.map { $0 }, [3, 2])

    list.append(1)
    list.moveToLast(value: 2)
    list.moveToLast(value: 3)
    list.append(4)
    list.append(5)
    list.append(6)
    list.append(7)
    list.append(8)
    list.moveToLast(value: 4)
    list.moveToLast(value: 5)
    list.moveToLast(value: 8)
    list.moveToLast(value: 8)
    XCTAssertEqual(list.map { $0 }, [1, 2, 3, 6, 7, 4, 5, 8])
  }
}
