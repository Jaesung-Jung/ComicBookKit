//
//  RARUnarchiver.swift
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

class RARUnarchiver {
    typealias Attributes = RARFileAttributes

    private let handle: RARHandle

    let fileURL: URL
    var isEncrypted: Bool {
        return handle.isEncrypted
    }

    lazy var fileAttributes: [Attributes] = {
        self.handle.attributes()
            .filter { !$0.isDirectory }
            .sorted { (lhs, rhs) in
                lhs.name < rhs.name
            }
    }()

    init?(constensOf url: URL, password: String?) {
        guard let handle = RARHandle(path: url.path, password: password) else {
            return nil
        }
        self.handle = handle
        self.fileURL = url
    }

    func unarchive(at index: Int, length: UInt = 0) -> Data? {
        guard let attributes = attributes(at: index) else {
            return nil
        }
        return unarchive(name: attributes.name, length: length)
    }

    func unarchive(name: String, length: UInt = 0) -> Data? {
        return handle.read(withName: name, length: length)
    }

    func validatePassword(_ password: String) -> Bool {
        return handle.validatePassword(password)
    }
}

extension RARUnarchiver {
    private func attributes(at index: Int) -> Attributes? {
        guard fileAttributes.indices.contains(index) else {
            return nil
        }
        return fileAttributes[index]
    }
}
