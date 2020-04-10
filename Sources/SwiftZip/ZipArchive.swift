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

/// An read-only archive.
public class ZipArchive {
    internal var handle: OpaquePointer!

    internal init(archiveHandle handle: OpaquePointer) {
        self.handle = handle
    }

    deinit {
        if let handle = handle {
            zip_discard(handle)
        }
    }
}

// MARK: - Error context

extension ZipArchive: ZipErrorContext {
    internal var lastError: zip_error_t? {
        return zip_get_error(handle).pointee
    }

    internal func clearError() {
        zip_error_clear(handle)
    }
}

// MARK: - Open/close archive

extension ZipArchive {
    /// Opens the zip archive specified by path and sets up an instance, used to manipulate the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_open](https://libzip.org/documentation/zip_open.html)
    ///
    /// - Parameters:
    ///   - path: path to open
    ///   - flags: open flags, defaults to `[]`
    public convenience init(path: String, flags: OpenFlags = []) throws {
        var status: Int32 = ZIP_ER_OK
        let optionalHandle = path.withCString { path in
            return zip_open(path, flags.rawValue | ZIP_RDONLY, &status)
        }

        try zipCheckError(status)
        let handle = try optionalHandle.unwrapped()
        self.init(archiveHandle: handle)
    }

    /// Opens the zip archive specified by URL and sets up an instance, used to manipulate the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_open](https://libzip.org/documentation/zip_open.html)
    ///
    /// - Parameters:
    ///   - url: URL to open
    ///   - flags: open flags, defaults to `[]`
    public convenience init(url: URL, flags: OpenFlags = []) throws {
        guard url.isFileURL else {
            throw ZipError.unsupportedURL
        }

        var status: Int32 = ZIP_ER_OK
        let optionalHandle: OpaquePointer? = try url.withUnsafeFileSystemRepresentation { path in
            if let path = path {
                return zip_open(path, flags.rawValue | ZIP_RDONLY, &status)
            } else {
                throw ZipError.internalInconsistency
            }
        }

        try zipCheckError(status)
        let handle = try optionalHandle.unwrapped()
        self.init(archiveHandle: handle)
    }

    /// Opens a zip archive encapsulated by the `ZipSource` and sets up an instance, used to manipulate the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_open_from_source](https://libzip.org/documentation/zip_open_from_source.html)
    ///
    /// - Parameters:
    ///   - source: source to open
    ///   - flags: open flags, defaults to `[]`
    public convenience init(source: ZipSource, flags: OpenFlags = []) throws {
        var error = zip_error()
        let optionalHandle = zip_open_from_source(source.handle, flags.rawValue | ZIP_RDONLY, &error)
        let handle = try optionalHandle.unwrapped(or: error)
        self.init(archiveHandle: handle)

        // compensate unbalanced `free` inside `zip_open_from_source`
        source.keep()
    }

    /// The zip archive specified by the open file descriptor `fd` is opened and an instance, used to manipulate
    /// the archive, is comfigured. In contrast to other initializers, the archive can only be opened in read-only mode.
    /// The `fd` argument may not be used any longer after calling `ZipArchive.init(fd:flags:)`.
    ///
    /// Upon successful completion `fd` should not be used any longer, nor passed to `close(2)`.
    /// In the error case, `fd` remains unchanged.
    ///
    /// - SeeAlso:
    ///   - [zip_fdopen](https://libzip.org/documentation/zip_fdopen.html)
    ///
    /// - Parameters:
    ///   - fd: file descriptor to use
    ///   - flags: open flags, defaults to `[]`
    public convenience init(fd: Int32, flags: FDOpenFlags = []) throws {
        var status: Int32 = ZIP_ER_OK
        let optionalHandle = zip_fdopen(fd, flags.rawValue | ZIP_RDONLY, &status)
        try zipCheckError(status)
        let handle = try optionalHandle.unwrapped()
        self.init(archiveHandle: handle)
    }

    /// Closes archive and frees the memory allocated for it. Any changes to the archive are not written to disk and discarded.
    /// The `ZipArchive` object is invalidated and must not be used after call to `dsicard()`.
    ///
    /// - SeeAlso:
    ///   - [zip_discard](https://libzip.org/documentation/zip_discard.html)
    public func discard() {
        zip_discard(handle)
        handle = nil
    }
}

// MARK: - Password handling

extension ZipArchive {
    /// Sets the default password used when accessing encrypted files. If password is `nil`, the default password is unset.
    /// If you prefer a different password for single files, pass password to `ZipArchive.open` or `ZipEntry.open` instead.
    /// Usually, however, the same password is used for every file in an zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_set_default_password](https://libzip.org/documentation/zip_set_default_password.html)
    ///
    /// - Parameters:
    ///   - password: the password to be used
    public func setDefaultPassword(_ password: String?) throws {
        if let password = password {
            try password.withCString { password in
                _ = try zipCheckResult(zip_set_default_password(handle, password))
            }
        } else {
            try zipCheckResult(zip_set_default_password(handle, nil))
        }
    }
}

// MARK: - Comments

extension ZipArchive {
    /// Returns the comment for the entire zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_get_archive_comment](https://libzip.org/documentation/zip_get_archive_comment.html)
    ///
    /// - Parameters:
    ///   - decodingStrategy: string decoding strategy, defaults to `.guess`
    ///   - version: archive version to use, defaults to `.current`
    public func getComment(decodingStrategy: ZipStringDecodingStrategy = .guess, version: Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_get_archive_comment(handle, nil, decodingStrategy.rawValue | version.rawValue)))
    }

    /// Returns the unmodified archive comment as it is in the ZIP archive.
    ///
    /// - SeeAlso:
    ///   - [zip_get_archive_comment](https://libzip.org/documentation/zip_get_archive_comment.html)
    ///
    /// - Parameters:
    ///   - version: archive version to use, defaults to `.current`
    public func getRawComment(version: Version = .current) throws -> Data {
        return try Data(cString: zipCheckResult(zip_get_archive_comment(handle, nil, ZIP_FL_ENC_RAW | version.rawValue)))
    }
}

// MARK: - Entry enumeration

extension ZipArchive {
    /// Returns the number of files in archive.
    ///
    /// - SeeAlso:
    ///   - [zip_get_num_entries](https://libzip.org/documentation/zip_get_num_entries.html)
    ///
    /// - Parameters:
    ///   - version: archive version to use, defaults to `.current`
    public func getEntryCount(version: Version = .current) throws -> Int {
        return try zipCast(zipCheckResult(zip_get_num_entries(handle, version.rawValue)))
    }

    /// Retrieves archive entry by index.
    ///
    /// - Parameters:
    ///   - index: index of entry to retrieve
    public func getEntry(index: Int, version: Version = .current) throws -> ZipEntry {
        return try ZipEntry(archive: self, entry: zipCast(index), version: version)
    }
}

// MARK: - Locate entry

extension ZipArchive {
    ///  Returns the index of the file named `filename` in archive. If archive does not contain a file
    ///  with that name, an error is thrown.
    ///
    /// - SeeAlso:
    ///   - [zip_name_locate](https://libzip.org/documentation/zip_name_locate.html)
    ///
    /// - Parameters:
    ///   - filename: entry name to locate
    ///   - locateFlags: lookup options, defaults to `[]`
    ///   - version: archive version to use, defaults to `.current`
    public func locate(filename: String, locateFlags: LocateFlags = [], version: Version = .current) throws -> ZipEntry {
        return try filename.withCString { filename in
            let index = try zipCheckResult(zip_name_locate(handle, filename, locateFlags.rawValue | version.rawValue | ZIP_FL_ENC_UTF_8))
            return try ZipEntry(archive: self, entry: zipCast(index), version: version)
        }
    }
}

// MARK: - Entry stats

extension ZipArchive {
    /// Obtains information about the file named `filename` in archive.
    ///
    /// - SeeAlso:
    ///   - [zip_stat](https://libzip.org/documentation/zip_stat.html)
    ///
    /// - Parameters:
    ///   - filename: entry name
    ///   - locateFlags: lookup options, defaults to `[]`
    ///   - version: archive version to use, defaults to `.current`
    public func stat(filename: String, locateFlags: LocateFlags = [], version: Version = .current) throws -> ZipEntry.Stat {
        var result = ZipEntry.Stat()
        let resultCode = filename.withCString { filename in
            return zip_stat(handle, filename, locateFlags.rawValue | version.rawValue, &result.stat)
        }

        try zipCheckResult(resultCode)
        return result
    }
}

// MARK: - Open entry for reading

extension ZipArchive {
    /// Opens the file named `filename` in archive using the password given in the password argument.
    ///
    /// - SeeAlso:
    ///   - [zip_fopen](https://libzip.org/documentation/zip_fopen.html)
    ///   - [zip_fopen_encrypted](https://libzip.org/documentation/zip_fopen_encrypted.html)
    ///
    /// - Parameters:
    ///   - filename: entry name to open
    ///   - flags: open flags, defaults to `[]`
    ///   - locateFlags: lookup options, defaults to `[]`
    ///   - version: archive version to use, defaults to `.current`
    ///   - password: optional password to decrypt the entry
    public func open(filename: String, flags: ZipEntry.OpenFlags = [], locateFlags: LocateFlags = [], version: Version = .current, password: String? = nil) throws -> ZipEntryReader {
        let entryHandle: OpaquePointer? = filename.withCString { filename in
            if let password = password {
                return password.withCString { password in
                    return zip_fopen_encrypted(handle, filename, flags.rawValue | locateFlags.rawValue | version.rawValue, password)
                }
            } else {
                return zip_fopen(handle, filename, flags.rawValue | locateFlags.rawValue | version.rawValue)
            }
        }

        return try ZipEntryReader(zipCheckResult(entryHandle))
    }
}
