//
//  ComicBookDocument.swift
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

import UIKit

public class ComicBookDocument<Key: Hashable> {
  private let cache = Cache<Key, UIImage>(capacity: 5)

  var pages: [ComicBookDocumentPage] = []

  public var pageCount: Int {
    return pages.count
  }

  public var isEncrypted: Bool {
    return false
  }

  public var password: String?

  public var rightToLeft: Bool = false {
    didSet {
      if rightToLeft != oldValue {
        didUpdatePageDirection(rightToLeft)
      }
    }
  }

  init() {
  }

  public func image(at index: Int) -> UIImage? {
    guard pages.indices.contains(index) else {
      return nil
    }

    let page = pages[index]
    guard let image = image(of: page.key) else {
      return nil
    }
    switch page.method {
    case .fill:
      return image
    case .left, .right:
      return image.cropping(to: page.rect)
    }
  }

  func image(of key: Key) -> UIImage? {
    if let image = cache[key] {
      return image
    }

    guard let data = data(of: key), let image = UIImage(data: data) else {
      return nil
    }
    cache[key] = image
    return image
  }

  func data(of key: Key) -> Data? {
    fatalError()
  }

  func validatePassword(_ password: String) -> Bool {
    fatalError()
  }

  func didUpdatePageDirection(_ rightToLeft: Bool) {
    pages = pages.map { page in
      switch page.method {
      case .fill:
        return page
      case .left:
        return ComicBookDocumentPage(key: page.key, size: page.size, method: .right)
      case .right:
        return ComicBookDocumentPage(key: page.key, size: page.size, method: .left)
      }
    }
  }
}

extension ComicBookDocument {
  struct ComicBookDocumentPage {
    let key: Key
    let size: CGSize
    let method: RenderingMethod
    var rect: CGRect {
      return method.rect(of: size)
    }
  }
}
