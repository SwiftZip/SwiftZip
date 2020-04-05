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

public final class ZipSource: ZipErrorContext {
    internal let handle: OpaquePointer

    // MARK: - Error Context

    internal var error: ZipError? {
        return .zipError(zip_source_error(handle).pointee)
    }

    // MARK: - Create/Destroy

    public init(buffer: UnsafeRawPointer, length: Int, freeWhenDone: Bool) throws {
        var error = zip_error_t()
        self.handle = try zip_source_buffer_create(buffer, zipCast(length), freeWhenDone ? 1 : 0, &error).unwrapped(or: error)
    }

    public init(filename: String, start: Int = 0, length: Int = -1) throws {
        self.handle = try filename.withCString { filename in
            var error = zip_error_t()
            return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
        }
    }

    public init(url: URL, start: Int = 0, length: Int = -1) throws {
        self.handle = try url.withUnsafeFileSystemRepresentation { filename in
            if let filename = filename {
                var error = zip_error_t()
                return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
            } else {
                throw ZipError.unsupportedURL
            }
        }
    }

    public init(file: UnsafeMutablePointer<FILE>, start: Int = 0, length: Int = -1) throws {
        var error = zip_error_t()
        self.handle = try zip_source_filep_create(file, zipCast(start), zipCast(length), &error).unwrapped(or: error)
    }

    public init(callback: @escaping zip_source_callback, userdata: UnsafeMutableRawPointer? = nil) throws {
        var error = zip_error_t()
        self.handle = try zip_source_function_create(callback, userdata, &error).unwrapped(or: error)
    }

    public init(callback: ZipSourceCallback) throws {
        var error = zip_error_t()
        let proxy = ZipSourceCallbackProxy(callback: callback)
        let userdata = Unmanaged.passRetained(proxy)

        do {
            self.handle = try zip_source_function_create(zipSourceCallbackProxy, userdata.toOpaque(), &error).unwrapped(or: error)
        } catch {
            userdata.release()
            throw error
        }
    }

    internal func keep() {
        zip_source_keep(handle)
    }

    deinit {
        zip_source_free(handle)
    }
}
