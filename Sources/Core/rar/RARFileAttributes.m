//
//  RARFileAttributes.m
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

#import "RARFileAttributes.h"

@interface RARFileAttributes ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) BOOL isDirectory;
@property (nonatomic, assign, readwrite) NSUInteger uncompressedSize;
@property (nonatomic, assign, readwrite) NSUInteger compressedSize;
@property (nonatomic, assign, readwrite) NSUInteger compressionMethod;
@property (nonatomic, assign, readwrite) NSUInteger crc;

@end

@implementation RARFileAttributes

- (instancetype)initWithName:(NSString *)name
                 isDirectory:(BOOL)isDirectory
            uncompressedSize:(NSUInteger)uncompressedSize
              compressedSize:(NSUInteger)compressedSize
           compressionMethod:(NSUInteger)compressionMethod
                         crc:(NSUInteger)crc {
    if (self = [super init]) {
        self.name = name;
        self.isDirectory = isDirectory;
        self.uncompressedSize = uncompressedSize;
        self.compressedSize = compressedSize;
        self.compressionMethod = compressionMethod;
        self.crc = crc;
    }
    return self;
}

@end
