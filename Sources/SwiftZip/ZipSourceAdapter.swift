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

/// A base protocol for all custom sources.
public protocol ZipSourceAdapter { }

/// A protocol for custom readable sources.
public protocol ZipSourceReadable: ZipSourceAdapter {
    func open() throws
    func read(to buffer: UnsafeMutableRawPointer, count: Int) throws -> Int
    func close() throws
    func stat() throws -> ZipStat
}

/// A protocol for custom readable and seekable sources.
public protocol ZipSourceSeekable: ZipSourceReadable {
    func seek(offset: Int, relativeTo whence: ZipWhence) throws
    func tell() throws -> Int
}

/// A protocol for custom writable sources.
public protocol ZipSourceWritable: ZipSourceAdapter {
    func beginWrite() throws
    func write(bytes: UnsafeMutableRawPointer, count: Int) throws -> Int
    func commitWrite() throws
    func rollbackWrite() throws
    func seekWrite(offset: Int, relativeTo whence: ZipWhence) throws
    func tellWrite() throws -> Int
    func remove() throws
}
