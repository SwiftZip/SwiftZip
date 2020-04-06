// SwiftZip -- Swift wrapper for libzip
//
// Copyright (c) 2019-2020 Victor Pavlychko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import zip

public struct ZipSourceStat {
    public var size: Int?
    public var compressedSize: Int?
    public var modificationDate: Date?
    public var crc32: UInt32?
    public var compressionMethod: ZipEntry.CompressionMethod?
    public var encryptionMethod: ZipEntry.EncryptionMethod?
    public var flags: UInt32?

    public init(size: Int? = nil, compressedSize: Int? = nil, modificationDate: Date? = nil, crc32: UInt32? = nil, compressionMethod: ZipEntry.CompressionMethod? = nil, encryptionMethod: ZipEntry.EncryptionMethod? = nil, flags: UInt32? = nil) {
        self.size = size
        self.compressedSize = compressedSize
        self.modificationDate = modificationDate
        self.crc32 = crc32
        self.compressionMethod = compressionMethod
        self.encryptionMethod = encryptionMethod
        self.flags = flags
    }
}

public protocol ZipSourceCallback { }

public protocol ZipSourceReadable: ZipSourceCallback {
    func open() throws
    func read(to buffer: UnsafeMutableRawPointer, count: Int) throws -> Int
    func close() throws
    func stat() throws -> ZipSourceStat
}

public protocol ZipSourceSeekable: ZipSourceReadable {
    func seek(offset: Int, whence: ZipWhence) throws
    func tell() throws -> Int
}

public protocol ZipSourceWritable: ZipSourceCallback {
    func beginWrite() throws
    func write(bytes: UnsafeMutableRawPointer, count: Int) throws -> Int
    func commitWrite() throws
    func rollbackWrite() throws
    func seekWrite(offset: Int, whence: ZipWhence) throws
    func tellWrite() throws -> Int
    func remove() throws
}
