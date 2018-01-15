//
//  ZIPDataIterator.swift
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

class ZIPDataIterator: IteratorProtocol {
    private let handle: ZIPHandle
    private let password: String?
    private let buffer: UnsafeMutablePointer<UInt8>
    private let bufferSize: Int

    let offset: UInt64

    init(handle: ZIPHandle, password: String?, offset: UInt64, bufferSize: Int) {
        self.handle = handle
        self.password = password
        self.buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        self.bufferSize = bufferSize
        self.offset = offset
        handle.seek(to: offset)
        handle.openCurrentFile()
    }

    deinit {
        buffer.deallocate(capacity: bufferSize * MemoryLayout<UInt8>.stride)
        handle.closeCurrentFile()
    }

    func next() -> Data? {
        return handle.read(on: buffer, bufferSize: bufferSize, readLength: bufferSize)
    }
}
