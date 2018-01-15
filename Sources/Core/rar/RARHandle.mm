//
//  RARHandle.m
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

#import "RARHandle.h"
#import "RARFileAttributes.h"
#import "rar.hpp"

int CALLBACK RARReadCallbackProc(UINT msg, long userData, long P1, long P2);
typedef void(^RARAction)(HANDLE handle);
typedef void(^RARReadHandler)(NSData *data);

@interface RARHandle() {
    HANDLE handle;
}

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) RARReadHandler readHandler;

@end

@implementation RARHandle

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path password:nil];
}

- (instancetype)initWithPath:(NSString *)path password:(NSString *)password {
    if (![RARHandle validateFile:path]) {
        return nil;
    }
    if (self = [super init]) {
        self.path = path;
        self.password = password;
    }
    return self;
}

- (NSArray<RARFileAttributes *> *)attributes {
    if (self.isEncrypted && ![self validatePassword:self.password]) {
        return @[];
    }

    __block NSMutableArray<RARFileAttributes *> *attributesList = [NSMutableArray array];
    [self openWithMode:RAR_OM_LIST_INCSPLIT password:self.password action:^(HANDLE handle) {
        NSInteger result = 0;
        RARHeaderDataEx header;
        while ((result = RARReadHeaderEx(handle, &header)) == 0) {
            NSString *name = [self stringFromUnichars:header.FileNameW];
            NSUInteger uncompressedSize = header.UnpSizeHigh << 32 | header.UnpSize;
            NSUInteger compressedSize = header.PackSizeHigh << 32 | header.PackSize;
            NSUInteger compressionMethod = header.Method;
            NSUInteger crc = header.FileCRC;
            BOOL isDirectory = header.Flags & RHDF_DIRECTORY;
            RARFileAttributes *attributes = [[RARFileAttributes alloc] initWithName:name
                                                                        isDirectory:isDirectory
                                                                   uncompressedSize:uncompressedSize
                                                                     compressedSize:compressedSize
                                                                  compressionMethod:compressionMethod
                                                                                crc:crc];
            [attributesList addObject:attributes];

            RARProcessFile(handle, RAR_SKIP, NULL, NULL,0);
        }
    }];
    return [NSArray arrayWithArray:attributesList];
}

- (NSData *)readWithName:(NSString *)name {
    return [self readWithName:name length:0];
}

- (NSData *)readWithName:(NSString *)name length:(NSUInteger)length {
    __block NSData *data;
    [self openWithMode:RAR_OM_EXTRACT password:self.password action:^(HANDLE handle) {
        RARHeaderDataEx header;
        NSUInteger uncompressedSize = 0;
        NSInteger result = 0;

        while ((result = RARReadHeaderEx(handle, &header)) == 0) {
            NSString *name = [self stringFromUnichars:header.FileNameW];
            if ([name isEqualToString:name]) {
                uncompressedSize = header.UnpSizeHigh << 32 | header.UnpSize;
                break;
            }
            RARProcessFile(handle, RAR_SKIP, NULL, NULL, 0);
        }
        if (uncompressedSize == 0) {
            return;
        }

        NSMutableData *uncompressedData = [NSMutableData dataWithCapacity:uncompressedSize];
        RARSetCallback(handle, RARReadCallbackProc, (long)(__bridge void *)self);
        self.readHandler = ^void(NSData *readedData) {
            [uncompressedData appendData:readedData];
        };
        RARProcessFile(handle, RAR_TEST, NULL, NULL, length);

        data = [NSData dataWithData:uncompressedData];
    }];

    return data;
}

- (BOOL)isEncrypted {
    return ![self validatePassword:nil];
}

- (BOOL)validatePassword:(NSString *)password {
    __block BOOL result = YES;
    [self openWithMode:RAR_OM_EXTRACT password:password action:^(HANDLE handle) {
        RARHeaderDataEx header;
        NSInteger RHResult = RARReadHeaderEx(handle, &header);
        NSInteger PFResult = RARProcessFile(handle, RAR_TEST, NULL, NULL, 1);

        if (RHResult == ERAR_MISSING_PASSWORD || PFResult == ERAR_MISSING_PASSWORD ||
            RHResult == ERAR_BAD_PASSWORD || PFResult == ERAR_BAD_PASSWORD) {
            result = NO;
        }
    }];
    return result;
}

#pragma mark - Private

- (void)openWithMode:(NSInteger)mode password:(NSString *)password action:(RARAction)action {
    RAROpenArchiveDataEx *flags = new RAROpenArchiveDataEx;
    bzero(flags, sizeof(RAROpenArchiveDataEx));

    const char *utf8Name = self.path.UTF8String;
    flags->ArcName = new char[strlen(utf8Name) + 1];
    strcpy(flags->ArcName, utf8Name);
    flags->OpenMode = mode;

    HANDLE handle = RAROpenArchiveEx(flags);
    if (password != nil) {
        RARSetPassword(handle, (char *)password.UTF8String);
    }
    action(handle);

    RARCloseArchive(handle);
    delete flags->ArcName;
    delete flags;
}

- (NSString *)stringFromUnichars:(wchar_t *)unichars {
    return [[NSString alloc] initWithBytes:unichars
                                    length:wcslen(unichars) * sizeof(*unichars)
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

+ (BOOL)validateFile:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!handle) {
        return NO;
    }

    NSData *data = [handle readDataOfLength:8];
    [handle closeFile];

    if (data.length < 8) {
        return NO;
    }

    UInt8 *bytes = (UInt8 *)data.bytes;

    if (bytes[0] != 0x52 ||
        bytes[1] != 0x61 ||
        bytes[2] != 0x72 ||
        bytes[3] != 0x21 ||
        bytes[4] != 0x1A ||
        bytes[5] != 0x07) {
        return NO;
    }

    if (bytes[6] == 0x00) {
        return YES;
    }

    if (bytes[6] == 0x01 &&
        bytes[7] == 0x00) {
        return YES;
    }
    return NO;
}

@end

int CALLBACK RARReadCallbackProc(UINT msg, long userData, long P1, long P2) {
    if (msg == UCM_PROCESSDATA) {
        RARHandle *handle = (__bridge RARHandle *)(void *)userData;
        NSData *data = [NSData dataWithBytesNoCopy:(UInt8 *)P1 length:P2 freeWhenDone:NO];
        handle.readHandler(data);
    }
    return  0;
}
