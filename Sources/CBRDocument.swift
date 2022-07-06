//
//  CBRDocument.swift
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
import RARKitPrivate

public class CBRDocument: ComicBookDocument<String> {
  private var unarchiver: RARUnarchiver

  public let url: URL

  public override var isEncrypted: Bool {
    return unarchiver.isEncrypted
  }

  public override var password: String? {
    didSet {
      guard password != oldValue else {
        return
      }
      unarchiver = RARUnarchiver(constensOf: url, password: password)!
      if pages.isEmpty {
        pages = makePages(unarchiver: unarchiver)
      }
    }
  }

  public init?(url: URL, rightToLeft: Bool = false) {
    guard let unarchiver = RARUnarchiver(constensOf: url, password: nil) else {
      return nil
    }
    self.unarchiver = unarchiver
    self.url = url
    super.init()
    self.rightToLeft = rightToLeft
    self.pages = makePages(unarchiver: unarchiver)
  }

  override func data(of name: String) -> Data? {
    return unarchiver.unarchive(name: name)
  }

  override func validatePassword(_ password: String) -> Bool {
    return unarchiver.validatePassword(password)
  }

  private func makePages(unarchiver: RARUnarchiver) -> [ComicBookDocumentPage] {
    return unarchiver.fileAttributes
      .flatMap { attributes -> [ComicBookDocumentPage] in
        var format: ImageFormat?
        var length: UInt = 4096
        while let data = unarchiver.unarchive(name: attributes.name, length: length) {
          if format == nil {
            format = ImageFormat(data: data)
          }
          guard let format = format else {
            return []
          }
          guard let size = imageSize(of: data, format: format) else {
            if data.count < length {
              return []
            }
            length += 4096
            continue
          }

          if size.width > size.height {
            let left = ComicBookDocumentPage(key: attributes.name, size: size, method: .left)
            let right = ComicBookDocumentPage(key: attributes.name, size: size, method: .right)
            return rightToLeft ? [right, left] : [left, right]
          } else {
            let page = ComicBookDocumentPage(key: attributes.name, size: size, method: .fill)
            return [page]
          }
        }
        return []
      }
  }
}
