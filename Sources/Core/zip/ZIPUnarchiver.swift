//
//  ZIPUnarchiver.swift
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
import minizip

class ZIPUnarchiver {
  let fileURL: URL
  let isEncrypted: Bool
  var password: String?
  lazy var fileAttributes: [ZIPFileAttributes] = {
    ZIPHandle(path: self.fileURL.path, password: password)!
      .map { $0.attributes() }
      .filter { !$0.isDirectory && !$0.isHidden && !$0.path.hasPrefix("__MACOSX/") }
      .sorted()
  }()

  init?(contentsOf url: URL) {
    guard let handle = ZIPHandle(path: url.path) else {
      return nil
    }
    fileURL = url
    handle.openCurrentFile()
    isEncrypted = handle.read(length: 1) == nil
    handle.closeCurrentFile()
  }

  func unarchive(at index: Int) -> Data? {
    guard let attributes = attributes(at: index) else {
      return nil
    }
    return unarchive(offset: attributes.offset)
  }

  func unarchive(offset: UInt64) -> Data? {
    guard let handle = ZIPHandle(path: fileURL.path, password: password) else {
      return nil
    }
    handle.seek(to: offset)
    handle.openCurrentFile()
    defer {
      handle.closeCurrentFile()
    }
    return handle.read()
  }

  func iterator(at index: Int) -> ZIPDataIterator? {
    guard let attributes = attributes(at: index) else {
      return nil
    }
    return iterator(offset: attributes.offset)
  }

  func iterator(offset: UInt64) -> ZIPDataIterator? {
    guard let handle = ZIPHandle(path: fileURL.path, password: password) else {
      return nil
    }
    return ZIPDataIterator(handle: handle, password: password, offset: offset, bufferSize: 4096)
  }
  
  func validatePassword(_ password: String) -> Bool {
    guard let handle = ZIPHandle(path: fileURL.path, password: password) else {
      return false
    }
    handle.openCurrentFile()
    defer {
      handle.closeCurrentFile()
    }
    return handle.read(length: 1) != nil
  }
}

extension ZIPUnarchiver {
  private func attributes(at index: Int) -> ZIPFileAttributes? {
    guard fileAttributes.indices.contains(index) else {
      return nil
    }
    return fileAttributes[index]
  }
}
