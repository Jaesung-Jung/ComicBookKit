//
//  ImageSize.swift
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
import CoreGraphics

func imageSize(of data: Data, format: ImageFormat) -> CGSize? {
    switch format {
    case .bmp:
        return bmpSize(of: data)
    case .jpeg:
        return jpegSize(of: data)
    case .gif:
        return gifSize(of: data)
    case .png:
        return pngSize(of: data)
    }
}

private func bmpSize(of data: Data) -> CGSize? {
    guard data.count >= 26 else {
        return nil
    }

    // Bitmap has BITAMPINFOHEADER for Windows or BITMAPCOREHEADER for OS/2.
    // BITMAPINFOHEADER has 4bytes of width and height size. minimum header size is 40byte.
    // BITMAPCOREHEADER has 2bytes of width and height size. minimum header size is 12byte.
    //
    // Bottom-up bitmap has a positive integer height,
    // and top-down bitmap has a negative integer height.
    let headerSize = data[14...17].fixedWidthInteger(UInt32.self).littleEndian
    if headerSize < 40 { // BITMAPCOREHEADER (OS/2)
        let w = abs(data[18...19].fixedWidthInteger(Int16.self).littleEndian)
        let h = abs(data[20...21].fixedWidthInteger(Int16.self).littleEndian)
        return CGSize(width: Int(w), height: Int(h))
    } else {
        let w = abs(data[18...21].fixedWidthInteger(Int32.self).littleEndian)
        let h = abs(data[22...25].fixedWidthInteger(Int32.self).littleEndian)
        return CGSize(width: Int(w), height: Int(h))
    }
}

private func jpegSize(of data: Data) -> CGSize? {
    var offset = 2
    while (offset + 8) < data.count {
        let marker1 = data[offset]
        if marker1 != 0xFF {
            return nil
        }

        let marker2 = data[offset + 1]
        if marker2 >= 0xC0 && marker2 <= 0xC2 { // SOF marker
            let w = data[offset+7...offset+8].fixedWidthInteger(Int16.self).bigEndian
            let h = data[offset+5...offset+6].fixedWidthInteger(Int16.self).bigEndian
            return CGSize(width: Int(w), height: Int(h))
        }

        let markerLength = data[offset+2...offset+3].fixedWidthInteger(Int16.self).bigEndian
        offset += Int(markerLength) + 2
    }
    return nil
}

private func gifSize(of data: Data) -> CGSize? {
    guard data.count >= 10 else {
        return nil
    }
    let w = data[6...7].fixedWidthInteger(Int16.self).littleEndian
    let h = data[8...9].fixedWidthInteger(Int16.self).littleEndian
    return CGSize(width: Int(w), height: Int(h))
}

private func pngSize(of data: Data) -> CGSize? {
    guard data.count >= 24 else {
        return nil
    }
    let w = data[16...19].fixedWidthInteger(Int32.self).bigEndian
    let h = data[20...23].fixedWidthInteger(Int32.self).bigEndian
    return CGSize(width: Int(w), height: Int(h))
}
