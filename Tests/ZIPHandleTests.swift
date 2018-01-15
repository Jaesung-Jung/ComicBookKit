//
//  ZIPHandleTests.swift
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

class ZIPHandleTests: XCTestCase, BundleResourceAccessible {
    func testCreation() {
        let handle1 = ZIPHandle(path: zipURL.path)
        let handle2 = ZIPHandle(path: zipURL.path)
        XCTAssertNotNil(handle1)
        XCTAssertNotNil(handle2)
    }

    func testAttributesWithIteration() {
        let handle = ZIPHandle(path: zipURL.path)!
        let attributes = handle
            .map { $0.attributes() }
            .filter {
                !$0.isDirectory && !$0.isHidden && !$0.path.hasPrefix("__MACOSX/")
            }
            .sorted()

        XCTAssertEqual(attributes.map { $0.path }, ["01.jpg", "02.jpg", "03.jpg", "04.jpg", "05.jpg", "06.jpg"])
    }

    func testRead() {
        let handle = ZIPHandle(path: zipURL.path)!
        handle.openCurrentFile()
        XCTAssertEqual(handle.read(length: 10)?.count, 10)
        handle.closeCurrentFile()
    }
}
