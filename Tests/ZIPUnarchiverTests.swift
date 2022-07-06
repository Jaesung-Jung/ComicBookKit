//
//  ZIPUnarchiverTests.swift
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

class ZIPUnarchiverTests: XCTestCase, BundleResourceAccessible {
  private var unarchiver: ZIPUnarchiver!

  override func setUp() {
    super.setUp()
    unarchiver = ZIPUnarchiver(contentsOf: zipURL)
  }

  func testCreation() {
    XCTAssertNotNil(unarchiver)
    XCTAssertEqual(unarchiver?.isEncrypted, false)
  }

  func testAttributes() {
    let attributes = unarchiver.fileAttributes
    XCTAssertEqual(attributes.count, 6)
    XCTAssertEqual(attributes[0].path, "01.jpg")
    XCTAssertEqual(attributes[0].isDirectory, false)
    XCTAssertEqual(attributes[0].isHidden, false)
    XCTAssertEqual(attributes[0].fileExtension, "jpg")
    XCTAssertEqual(attributes[0].compressedSize, 122697)
    XCTAssertEqual(attributes[0].uncompressedSize, 122804)
    XCTAssertEqual(attributes[0].crc, 2324891915)
    XCTAssertEqual(attributes[0].offset, 685722)
  }

  func testUnarchive() {
    guard let data = unarchiver.unarchive(at: 0) else {
      XCTFail("Failed unarchive")
      return
    }
    let image = UIImage(data: data)
    XCTAssertNotNil(image)
    XCTAssertEqual(image?.size, CGSize(width: 960, height: 640))
  }

  func testIterator() {
    let iterator = unarchiver.iterator(at: 0)
    var data = Data()
    while let readedData = iterator?.next() {
      data.append(readedData)
    }
    XCTAssertFalse(data.isEmpty)

    let image = UIImage(data: data)
    XCTAssertNotNil(image)
    XCTAssertEqual(image?.size, CGSize(width: 960, height: 640))
  }
}
