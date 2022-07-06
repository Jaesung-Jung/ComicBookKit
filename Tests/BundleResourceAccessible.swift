//
//  BundleResourceAccessible.swift
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

protocol BundleResourceAccessible {
}

extension BundleResourceAccessible where Self: XCTestCase {
  func url(name: String, withExtension ext: String) -> URL {
    return Bundle(for: type(of: self)).url(forResource: name, withExtension: ext)!
  }

  func resource(name: String, withExtension ext: String) -> Data {
    return try! Data(contentsOf: url(name: name, withExtension: ext))
  }

  var zipURL: URL {
    return url(name: "sample", withExtension: "zip")
  }

  var rarURL: URL {
    return url(name: "sample", withExtension: "rar")
  }

  var bmp: Data {
    return resource(name: "bmp", withExtension: "bmp")
  }

  var gif: Data {
    return resource(name: "gif", withExtension: "gif")
  }

  var jpeg: Data {
    return resource(name: "jpeg", withExtension: "jpg")
  }

  var png: Data {
    return resource(name: "png", withExtension: "png")
  }
}
