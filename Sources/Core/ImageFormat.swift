//
//  ImageFormat.swift
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

enum ImageFormat {
    case bmp
    case jpeg
    case gif
    case png

    init?(data: Data) {
        if data.hasPrefix(ImageFormat.bmp.signature) {
            self = .bmp
        } else if data.hasPrefix(ImageFormat.jpeg.signature) {
            self = .jpeg
        } else if data.hasPrefix(ImageFormat.gif.signature) {
            self = .gif
        } else if data.hasPrefix(ImageFormat.png.signature) {
            self = .png
        } else {
            return nil
        }
    }

    var signature: Data {
        switch self {
        case .bmp:
            return Data(bytes: [0x42, 0x4D])
        case .jpeg:
            return Data(bytes: [0xFF, 0xD8])
        case .gif:
            return Data(bytes: [0x47, 0x49, 0x46])
        case .png:
            return Data(bytes: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        }
    }
}
