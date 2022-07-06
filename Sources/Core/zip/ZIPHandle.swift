//
//  ZIPHandle.swift
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

class ZIPHandle {
    private let path: String
    private let handle: unzFile
    private let password: String?

    init?(path: String, password: String? = nil) {
        guard let handle = unzOpen64(path) else {
            return nil
        }
        self.path = path
        self.handle = handle
        self.password = password
        seekToFirst()
    }

    deinit {
        unzClose(handle)
    }

    func seekToFirst() {
        unzGoToFirstFile(handle)
    }

    @discardableResult
    func seekToNext() -> Bool {
        return unzGoToNextFile(handle) == UNZ_OK
    }

    @discardableResult
    func seek(to offset: UInt64) -> Bool {
        return unzSetOffset64(handle, offset) == UNZ_OK
    }

    func attributes() -> ZIPFileAttributes {
        var info = unz_file_info64()
        unzGetCurrentFileInfo64(handle, &info, nil, 0, nil, 0, nil, 0)

        let bufferSize = Int(info.size_filename + 1)
        let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
        buffer.initialize(repeating: 0, count: bufferSize)
        defer {
            buffer.deallocate()
        }

        unzGetCurrentFileInfo64(handle, nil, buffer, UInt(bufferSize - 1), nil, 0, nil, 0)

        let path = String(cString: buffer)
        return ZIPFileAttributes(
            path: path,
            fileExtension: path.pathExtension,
            isDirectory: path.last == "/",
            isHidden: path.lastPathComponent.first == ".",
            offset: unzGetOffset64(handle),
            compressedSize: info.compressed_size,
            uncompressedSize: info.uncompressed_size,
            crc: info.crc
        )
    }

    @discardableResult
    func openCurrentFile() -> Bool {
        guard let password = password else {
            return unzOpenCurrentFile(handle) == UNZ_OK
        }
        return unzOpenCurrentFilePassword(handle, password) == UNZ_OK
    }

    @discardableResult
    func closeCurrentFile() -> Bool {
        return unzCloseCurrentFile(handle) == UNZ_OK
    }

    func read(length: Int = .max) -> Data? {
        let bufferSize = Swift.min(65536, length)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        return read(on: buffer, bufferSize: bufferSize, readLength: length)
    }

    func read(on buffer: UnsafeMutablePointer<UInt8>, bufferSize: Int, readLength: Int) -> Data? {
        var data = Data()
        var readedLength = 0
        while readedLength < readLength {
            let length = unzReadCurrentFile(handle, buffer, UInt32(bufferSize))
            if length > 0 {
                data.append(Data(bytes: buffer, count: Int(length)))
                readedLength += Int(length)
            } else {
                return data.isEmpty ? nil : data
            }
        }
        return data.isEmpty ? nil : data
    }
}

extension ZIPHandle: Sequence {
    class Iterator: IteratorProtocol {
        private var isFirstElement = true
        private let handle: ZIPHandle

        init(path: String, password: String?) {
            handle = ZIPHandle(path: path, password: password)!
        }

        func next() -> ZIPHandle? {
            if isFirstElement {
                isFirstElement = false
                return handle
            }
            guard handle.seekToNext() else {
                return nil
            }
            return handle
        }
    }
                
    func makeIterator() -> ZIPHandle.Iterator {
        return Iterator(path: path, password: password)
    }
}

extension String {
    var lastPathComponent: String {
        guard last != "/" else {
            return self
        }
        guard let reversedIndex = lastIndex(of: "/") else {
            return self
        }
        return String(self[reversedIndex...])
    }

    var pathExtension: String {
        let name = lastPathComponent
        guard let range = name.rangeOfCharacter(from: ["."]) else {
            return ""
        }
        return String(name[range.upperBound...])
    }
}
