//
//  CacheTests.swift
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

class CacheTests: XCTestCase {
    func testCache() {
        let cache = Cache<String, Int>(capacity: 3)
        cache.setValue(1, forKey: "one")
        cache.setValue(2, forKey: "two")
        cache.setValue(3, forKey: "three")

        XCTAssertEqual(cache["one"], 1)
        XCTAssertEqual(cache["two"], 2)
        XCTAssertEqual(cache["three"], 3)
        XCTAssertEqual(cache.keys.map { $0 }, ["one", "two", "three"])

        cache.setValue(4, forKey: "four")
        XCTAssertEqual(cache["four"], 4)
        XCTAssertNil(cache["one"])
        XCTAssertEqual(cache.keys.map { $0 }, ["two", "three", "four"])

        cache.setValue(2, forKey: "two")
        XCTAssertEqual(cache.keys.map { $0 }, ["three", "four", "two"])

        cache.setValue(5, forKey: "five")
        XCTAssertEqual(cache.keys.map { $0 }, ["four", "two", "five"])
    }
}
