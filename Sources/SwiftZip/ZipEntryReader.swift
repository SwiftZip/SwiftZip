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

import zip

public final class ZipEntryReader: ZipErrorContext {
    internal var handle: OpaquePointer!

    internal init(_ handle: OpaquePointer) {
        self.handle = handle
    }

    deinit {
        if let handle = handle {
            let result = zip_fclose(handle)
            assert(result == ZIP_ER_OK, "Failed to close file, error code: \(result)")
        }
    }

    // MARK: - Error Context

    internal var error: zip_error_t? {
        return zip_file_get_error(handle).pointee
    }

    internal func clearError() {
        zip_file_error_clear(handle)
    }

    // MARK: - Open/Close

    /// Closes the file and invalidates `ZipEntryReader` instance.
    ///
    /// - SeeAlso:
    ///   - [zip_fclose](https://libzip.org/documentation/zip_fclose.html)
    public func close() {
        let result = zip_fclose(handle)
        assert(result == ZIP_ER_OK, "Failed to close file, error code: \(result)")
        handle = nil
    }

    // MARK: - Entry I/O

    /// Reads at most `count` bytes from file into `buf`.
    /// Returns number of bytes read.
    ///
    /// - SeeAlso:
    ///   - [zip_fread](https://libzip.org/documentation/zip_fread.html)
    ///
    /// - Parameters:
    ///   - buf: destination data buffer
    ///   - count: buffer size
    @discardableResult
    public func read(buf: UnsafeMutableRawPointer, count: Int) throws -> Int {
        return try zipCast(zipCheckResult(zip_fread(handle, buf, zipCast(count))))
    }

    /// Reads at most `count` bytes from file into `buf`.
    /// Returns number of bytes read.
    ///
    /// - SeeAlso:
    ///   - [zip_fread](https://libzip.org/documentation/zip_fread.html)
    ///
    /// - Parameters:
    ///   - buf: destination data buffer
    @discardableResult
    public func read(buf: UnsafeMutableRawBufferPointer) throws -> Int {
        return try read(buf: buf.baseAddress.forceUnwrap(), count: buf.count)
    }

    /// Seeks to the specified `offset` relative to `whence`, just like `fseek(3)`
    ///
    /// - SeeAlso:
    ///   - [zip_fseek](https://libzip.org/documentation/zip_fseek.html)
    ///
    /// - Parameters:
    ///   - offset: relative offset
    ///   - whence: anchor point
    public func seek(offset: Int, whence: ZipWhence = .cur) throws {
        try zipCheckResult(zip_fseek(handle, zipCast(offset), whence.rawValue))
    }

    /// Reports the current offset in the file. `tell` only works on uncompressed (stored) data.
    /// When called on compressed data it will throw an error.
    ///
    /// - SeeAlso:
    ///   - [zip_ftell](https://libzip.org/documentation/zip_ftell.html)
    public func tell() throws -> Int {
        return try zipCast(zipCheckResult(zip_ftell(handle)))
    }
}
