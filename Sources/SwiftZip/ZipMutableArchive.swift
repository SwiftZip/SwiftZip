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

/// An mutable archive.
public final class ZipMutableArchive: ZipArchive {
    internal init(mutableArchiveHandle handle: OpaquePointer) throws {
        if zip_get_archive_flag(handle, ZIP_AFL_RDONLY, 0) == 0 {
            super.init(archiveHandle: handle)
        } else {
            throw ZipError.archiveNotMutable
        }
    }
}

// MARK: - Open/close archive

extension ZipMutableArchive {
    /// Opens the zip archive specified by path and sets up an instance, used to manipulate the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_open](https://libzip.org/documentation/zip_open.html)
    ///
    /// - Parameters:
    ///   - path: path to open
    ///   - flags: open flags, defaults to `[]`
    public convenience init(path: String, flags: MutableOpenFlags = []) throws {
        var status: Int32 = ZIP_ER_OK
        let optionalHandle = path.withCString { path in
            return zip_open(path, flags.rawValue, &status)
        }

        try zipCheckError(status)
        let handle = try optionalHandle.unwrapped()
        try self.init(mutableArchiveHandle: handle)
    }

    /// Opens the zip archive specified by URL and sets up an instance, used to manipulate the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_open](https://libzip.org/documentation/zip_open.html)
    ///
    /// - Parameters:
    ///   - url: URL to open
    ///   - flags: open flags, defaults to `[]`
    public convenience init(url: URL, flags: MutableOpenFlags = []) throws {
        guard url.isFileURL else {
            throw ZipError.unsupportedURL
        }

        var status: Int32 = ZIP_ER_OK
        let optionalHandle: OpaquePointer? = try url.withUnsafeFileSystemRepresentation { path in
            if let path = path {
                return zip_open(path, flags.rawValue, &status)
            } else {
                throw ZipError.internalInconsistency
            }
        }

        try zipCheckError(status)
        let handle = try optionalHandle.unwrapped()
        try self.init(mutableArchiveHandle: handle)
    }

    /// Opens a zip archive encapsulated by the `ZipSource` and sets up an instance, used to manipulate the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_open_from_source](https://libzip.org/documentation/zip_open_from_source.html)
    ///
    /// - Parameters:
    ///   - source: source to open
    ///   - flags: open flags, defaults to `[]`
    public convenience init(source: ZipSource, flags: MutableOpenFlags = []) throws {
        var error = zip_error()
        let optionalHandle = zip_open_from_source(source.handle, flags.rawValue, &error)
        let handle = try optionalHandle.unwrapped(or: error)
        try self.init(mutableArchiveHandle: handle)

        // compensate unbalanced `free` inside `zip_open_from_source`
        source.keep()
    }

    /// Writes any changes made to archive to disk. If archive contains no files, the file is completely removed (no empty
    /// archive is written). If successful, archive is invalidated, otherwise archive is left unchanged.
    ///
    /// - SeeAlso:
    ///   - [zip_close](https://libzip.org/documentation/zip_close.html)
    public func close() throws {
        try zipCheckResult(zip_close(handle))
        handle = nil
    }
}

// MARK: - Comments

extension ZipMutableArchive {
    /// Sets the comment for the entire zip archive. If `comment` is set to `nil`,
    /// the comment is deleted from the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_set_archive_comment](https://libzip.org/documentation/zip_set_archive_comment.html)
    ///
    /// - Parameters:
    ///   - comment: new comment value
    public func setComment(_ comment: String?) throws {
        if let comment = comment {
            try comment.withCString { comment in
                _ = try zipCheckResult(zip_set_archive_comment(handle, comment, integerCast(strlen(comment))))
            }
        } else {
            try zipCheckResult(zip_set_archive_comment(handle, nil, 0))
        }
    }
}

// MARK: - Entry enumeration

extension ZipMutableArchive {
    /// Retrieves archive entry by index using the original data from the zip archive,
    /// ignoring any changes made to the file.
    ///
    /// - Parameters:
    ///   - index: index of entry to retrieve
    public func getMutableEntry(index: Int) throws -> ZipMutableEntry {
        return try ZipMutableEntry(archive: self, entry: integerCast(index), version: .current)
    }
}

// MARK: - Add/remove entries

extension ZipMutableArchive {
    /// Adds a directory to a zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_dir_add](https://libzip.org/documentation/zip_dir_add.html)
    ///
    /// - Parameters:
    ///   - name: the directory's name in the zip archive
    @discardableResult
    public func addDirectory(name: String) throws -> ZipMutableEntry {
        let index: zip_uint64_t = try name.withCString { name in
            return try integerCast(zipCheckResult(zip_dir_add(handle, name, ZIP_FL_ENC_UTF_8)))
        }

        return ZipMutableEntry(archive: self, entry: index, version: .current)
    }

    /// Adds a file to a zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_add](https://libzip.org/documentation/zip_file_add.html)
    ///
    /// - Parameters:
    ///   - name: the file's name in the zip archive
    ///   - source: the data of the file
    ///   - flags: operation flags, defaults to `[]`
    @discardableResult
    public func addFile(name: String, source: ZipSource, flags: AddFileFlags = []) throws -> ZipMutableEntry {
        let index: zip_uint64_t = try name.withCString { name in
            return try integerCast(zipCheckResult(zip_file_add(handle, name, source.handle, flags.rawValue | ZIP_FL_ENC_UTF_8)))
        }

        // compensate unbalanced `free` inside `zip_file_add`
        source.keep()
        return ZipMutableEntry(archive: self, entry: index, version: .current)
    }
}

// MARK: - Revert changes

extension ZipMutableArchive {
    /// Revert all global changes to the archive.
    /// This reverts changes to the archive comment and global flags.
    ///
    /// - SeeAlso:
    ///   - [zip_unchange_archive](https://libzip.org/documentation/zip_unchange_archive.html)
    public func unchangeGlobals() throws {
        try zipCheckResult(zip_unchange_archive(handle))
    }

    /// All changes to files and global information in archive are reverted.
    ///
    /// - SeeAlso:
    ///   - [zip_unchange_all](https://libzip.org/documentation/zip_unchange_all.html)
    public func unchangeAll() throws {
        try zipCheckResult(zip_unchange_all(handle))
    }
}
