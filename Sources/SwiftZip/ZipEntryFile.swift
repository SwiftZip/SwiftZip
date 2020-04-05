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

public final class ZipEntryFile: ZipErrorContext {
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

    internal var error: ZipError? {
        return .zipError(zip_file_get_error(handle).pointee)
    }

    // MARK: - Open/Close

    public func close() {
        let result = zip_fclose(handle)
        assert(result == ZIP_ER_OK, "Failed to close file, error code: \(result)")
        handle = nil
    }

    // MARK: - Entry I/O

    @discardableResult
    public func read(buf: UnsafeMutableRawPointer, count: Int) throws -> Int {
        return try zipCast(zipCheckResult(zip_fread(handle, buf, zipCast(count))))
    }

    public struct Whence: RawRepresentable, Equatable {
        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let set = Whence(rawValue: SEEK_SET)
        public static let cur = Whence(rawValue: SEEK_CUR)
        public static let end = Whence(rawValue: SEEK_END)
    }

    public func seek(offset: Int, whence: Whence) throws {
        try zipCheckResult(zip_fseek(handle, zipCast(offset), whence.rawValue))
    }

    public func tell() throws -> Int {
        return try zipCast(zipCheckResult(zip_ftell(handle)))
    }
}
