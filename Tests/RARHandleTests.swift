//
//  RARHandleTests.swift
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
import RARKitPrivate
@testable import ComicBookKit

class RARHandleTests: XCTestCase, BundleResourceAccessible {
  func testAttributes() {
    let handle = RARHandle(path: rarURL.path)!
    let attributes = handle.attributes()
    XCTAssertEqual(attributes.map { $0.name }, ["01.jpg", "02.jpg", "03.jpg", "04.jpg", "05.jpg", "06.jpg"])
  }

  func testRead() {
    let handle = RARHandle(path: rarURL.path)!
    let attributes = handle.attributes()
    let data = handle.read(withName: attributes[0].name)
    XCTAssertNotNil(data)

    let image = UIImage(data: data!)
    XCTAssertNotNil(image)
  }
  
  func testReadWithLength() {
    let handle = RARHandle(path: rarURL.path)!
    let attributes = handle.attributes()
    XCTAssertEqual(handle.read(withName: attributes[0].name, length: 256)?.count, 256)
    XCTAssertEqual(handle.read(withName: attributes[0].name, length: 1)?.count, 1)
  }
}
