//
//  CBZDocumentTests.swift
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

class CBZDocumentTests: XCTestCase, BundleResourceAccessible {
    var document: CBZDocument!

    override func setUp() {
        super.setUp()
        document = CBZDocument(url: zipURL)
    }

    func testCreation() {
        XCTAssertNotNil(document)
        XCTAssertEqual(document?.url, zipURL)
    }

    func testPages() {
        XCTAssertEqual(document?.pageCount, 12)

        let first = document?.pages[0]
        XCTAssertEqual(first?.method, .left)
        XCTAssertEqual(first?.rect, CGRect(x: 0, y: 0, width: 480, height: 640))

        let second = document?.pages[1]
        XCTAssertEqual(second?.method, .right)
        XCTAssertEqual(second?.rect, CGRect(x: 480, y: 0, width: 480, height: 640))
    }

    func testImages() {
        let firstImage = document.image(at: 0)
        XCTAssertNotNil(firstImage)
        XCTAssertEqual(firstImage?.size, CGSize(width: 480, height: 640))

        let secondImage = document.image(at: 1)
        XCTAssertNotNil(secondImage)
        XCTAssertEqual(secondImage?.size, CGSize(width: 480, height: 640))
    }

    func testRightToLeft() {
        let document = CBZDocument(url: zipURL, rightToLeft: true)
        let rfirst = document?.pages[0]
        XCTAssertEqual(rfirst?.method, .right)

        let rsecond = document?.pages[1]
        XCTAssertEqual(rsecond?.method, .left)

        document?.rightToLeft = false
        let lfirst = document?.pages[0]
        XCTAssertEqual(lfirst?.method, .left)

        let lsecond = document?.pages[1]
        XCTAssertEqual(lsecond?.method, .right)
    }

    func testPassword() {
        let url = self.url(name: "enc-sample", withExtension: "zip")
        let document = CBZDocument(url: url)

        XCTAssertTrue(document?.isEncrypted ?? false)
        XCTAssertNil(document?.image(at: 0))

        XCTAssertFalse(document?.validatePassword("****") ?? true)
        XCTAssertTrue(document?.validatePassword("1234") ?? false)

        document?.password = "1234"
        XCTAssertNotNil(document?.image(at: 0))
    }
}
