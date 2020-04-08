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

/// A `ZipSource` class wraps a data source used by `libzip(3)` for adding or replacing file contents
/// for a file in a zip archive. If the source supports seeking, it can also be used to open zip archives from.
public final class ZipSource {
    internal let handle: OpaquePointer

    deinit {
        zip_source_free(handle)
    }

    // MARK: - Create/Destroy

    /// Create a zip source from the `buffer` data of size `length`. If `freeWhenDone` is `true`, the buffer
    /// will be freed when it is no longer needed. `buffer` must remain valid for the lifetime of the created source.
    ///
    /// - SeeAlso:
    ///   - [zip_source_buffer_create](https://libzip.org/documentation/zip_source_buffer_create.html)
    ///
    /// - Parameters:
    ///   - buffer: data buffer
    ///   - length: data size
    ///   - freeWhenDone: buffer ownership flag
    public init(buffer: UnsafeRawPointer, length: Int, freeWhenDone: Bool) throws {
        var error = zip_error_t()
        self.handle = try zip_source_buffer_create(buffer, zipCast(length), freeWhenDone ? 1 : 0, &error).unwrapped(or: error)
    }

    /// Create a zip source from a file. Opens `path` and read `length` bytes from offset `start` from it.
    /// If `length` is 0 or -1, the whole file (starting from `start`) is used.
    /// If the file supports seek, the source can be used to open a zip archive from.
    /// The file is opened and read when the data from the source is used.
    ///
    /// - SeeAlso:
    ///   - [zip_source_file_create](https://libzip.org/documentation/zip_source_file_create.html)
    ///
    /// - Parameters:
    ///   - filename: file path to open
    ///   - start: data offset, defaults to 0
    ///   - length: data length, defaults to -1
    public init(path: String, start: Int = 0, length: Int = -1) throws {
        self.handle = try path.withCString { path in
            var error = zip_error_t()
            return try zip_source_file_create(path, zipCast(start), zipCast(length), &error).unwrapped(or: error)
        }
    }

    /// Create a zip source from a file. Opens `url` and read `length` bytes from offset `start` from it.
    /// If `length` is 0 or -1, the whole file (starting from `start`) is used.
    /// If the file supports seek, the source can be used to open a zip archive from.
    /// The file is opened and read when the data from the source is used.
    ///
    /// - SeeAlso:
    ///   - [zip_source_file_create](https://libzip.org/documentation/zip_source_file_create.html)
    ///
    /// - Parameters:
    ///   - url: file URL to open
    ///   - start: data offset, defaults to 0
    ///   - length: data length, defaults to -1
    public init(url: URL, start: Int = 0, length: Int = -1) throws {
        self.handle = try url.withUnsafeFileSystemRepresentation { path in
            if let path = path {
                var error = zip_error_t()
                return try zip_source_file_create(path, zipCast(start), zipCast(length), &error).unwrapped(or: error)
            } else {
                throw ZipError.unsupportedURL
            }
        }
    }

    /// Create a zip source from a file stream. Reads `length` bytes from offset `start` from the open
    /// file stream `file`. If `length` is 0 or -1, the whole file (starting from `start`) is used.
    /// If the file stream supports seeking, the source can be used to open a read-only zip archive from.
    /// The `file` stream is closed when the source is being freed.
    ///
    /// - SeeAlso:
    ///   - [zip_source_filep_create](https://libzip.org/documentation/zip_source_filep_create.html)
    ///
    /// - Parameters:
    ///   - file: file stream to use
    ///   - start: data offset, defaults to 0
    ///   - length: data length, defaults to -1
    public init(file: UnsafeMutablePointer<FILE>, start: Int = 0, length: Int = -1) throws {
        var error = zip_error_t()
        self.handle = try zip_source_filep_create(file, zipCast(start), zipCast(length), &error).unwrapped(or: error)
    }

    /// Creates a zip source from the user-provided function `callback`.
    ///
    /// - SeeAlso:
    ///   - [zip_source_function_create](https://libzip.org/documentation/zip_source_function_create.html)
    ///
    /// - Parameters:
    ///   - callback: user-defined callback function
    ///   - userdata: custom data to be passed to `callback`
    public init(callback: @escaping zip_source_callback, userdata: UnsafeMutableRawPointer? = nil) throws {
        var error = zip_error_t()
        self.handle = try zip_source_function_create(callback, userdata, &error).unwrapped(or: error)
    }

    /// Creates a zip source from the user-provided `callback` instance.
    /// The `callback` must conform to `ZipSourceReadable`, `ZipSourceSeekable`, or `ZipSourceWritable` protocols.
    ///
    /// - SeeAlso:
    ///   - [zip_source_function_create](https://libzip.org/documentation/zip_source_function_create.html)
    ///
    /// - Parameters:
    ///   - callback: user-provided callback instance
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
}
