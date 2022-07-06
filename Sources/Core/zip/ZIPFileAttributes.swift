//
//  ZIPFileAttributes.swift
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

import Foundation

struct ZIPFileAttributes {
  let path: String
  let fileExtension: String
  let isDirectory: Bool
  let isHidden: Bool
  let offset: UInt64
  let compressedSize: UInt64
  let uncompressedSize: UInt64
  let crc: UInt
}

extension ZIPFileAttributes: Comparable {
  static func<(lhs: ZIPFileAttributes, rhs: ZIPFileAttributes) -> Bool {
    let l = lhs.path.split(separator: "/")
    let r = rhs.path.split(separator: "/")
    let range = 0..<max(l.count, r.count)
    for index in range {
      if !l.indices.contains(index) {
        return true
      }
      if !r.indices.contains(index) {
        return false
      }
      if l[index].lowercased() > r[index].lowercased() {
        if l.count == 1 && r.count > 1 {
          return true
        }
        return false
      }
      if l[index].lowercased() < r[index].lowercased() {
        if r.count == 1 && l.count > 1 {
          return false
        }
        return true
      }
    }
    if l.count < r.count {
      return true
    }
    if l.count > r.count {
      return false
    }
    return false
  }

  static func>(lhs: ZIPFileAttributes, rhs: ZIPFileAttributes) -> Bool {
    return !(lhs < rhs)
  }

  static func<=(lhs: ZIPFileAttributes, rhs: ZIPFileAttributes) -> Bool {
    return lhs == rhs || lhs < rhs
  }

  static func>=(lhs: ZIPFileAttributes, rhs: ZIPFileAttributes) -> Bool {
    return lhs == rhs || lhs > rhs
  }

  static func==(lhs: ZIPFileAttributes, rhs: ZIPFileAttributes) -> Bool {
    return lhs.path == rhs.path
  }
}
