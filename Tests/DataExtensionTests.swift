//
//  DataExtensionTests.swift
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

class DataExtensionTests: XCTestCase {
  func testHasPrefix() {
    let prefix = Data([0, 1, 2])
    let data = Data([0, 1, 2, 3, 4, 5])
    XCTAssertTrue(data.hasPrefix(prefix))
  }

  func testFixedWidthInteger() {
    let data = Data([1, 0, 0, 0])
    // byte order 00 00 00 01
    XCTAssertEqual(data.fixedWidthInteger(UInt32.self).littleEndian, 1)
    // byte order 01 00 00 00
    XCTAssertEqual(data.fixedWidthInteger(UInt32.self).bigEndian, 16777216)
  }
}
