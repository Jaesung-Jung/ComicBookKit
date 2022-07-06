//
//  CBZDocument.swift
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

public class CBZDocument: ComicBookDocument<UInt64> {
  private let unarchiver: ZIPUnarchiver

  public let url: URL

  public override var isEncrypted: Bool {
    return unarchiver.isEncrypted
  }

  public override var password: String? {
    didSet {
      guard password != oldValue else {
        return
      }
      unarchiver.password = password
      if pages.isEmpty {
        pages = makePages(unarchiver: unarchiver)
      }
    }
  }

  public init?(url: URL, rightToLeft: Bool = false) {
    guard let unarchiver = ZIPUnarchiver(contentsOf: url) else {
      return nil
    }
    self.unarchiver = unarchiver
    self.url = url
    super.init()
    self.rightToLeft = rightToLeft
    self.pages = makePages(unarchiver: unarchiver)
  }

  override func data(of offset: UInt64) -> Data? {
    return unarchiver.unarchive(offset: offset)
  }

  override func validatePassword(_ password: String) -> Bool {
    return unarchiver.validatePassword(password)
  }

  private func makePages(unarchiver: ZIPUnarchiver) -> [ComicBookDocumentPage] {
    return unarchiver.fileAttributes
      .compactMap { unarchiver.iterator(offset: $0.offset) }
      .flatMap { iterator -> [ComicBookDocumentPage] in
        var data = Data()
        var format: ImageFormat?
        while let next = iterator.next() {
          data.append(next)
          if format == nil {
            format = ImageFormat(data: data)
          }
          guard let format = format else {
            return []
          }
          guard let size = imageSize(of: data, format: format) else {
            continue
          }

          if size.width > size.height {
            let left = ComicBookDocumentPage(key: iterator.offset, size: size, method: .left)
            let right = ComicBookDocumentPage(key: iterator.offset, size: size, method: .right)
            return rightToLeft ? [right, left] : [left, right]
          } else {
            let page = ComicBookDocumentPage(key: iterator.offset, size: size, method: .fill)
            return [page]
          }
        }
        return []
      }
  }
}
