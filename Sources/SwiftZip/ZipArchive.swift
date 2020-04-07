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

public final class ZipArchive: ZipErrorContext {
    internal var handle: OpaquePointer!

    deinit {
        if let handle = handle {
            zip_discard(handle)
        }
    }

    // MARK: - Error Context

    internal var error: ZipError? {
        return .zipError(zip_get_error(handle).pointee)
    }

    // MARK: - Open/Close Archive

    /// Opens the zip archive specified by path and sets up an instance, used to manipulate the archive.
    ///
    /// - Parameters:
    ///   - path: path to open
    ///   - flags: open flags, defaults to `[.readOnly]`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_open.html
    public init(path: String, flags: OpenFlags = [.readOnly]) throws {
        var status: Int32 = ZIP_ER_OK
        let handle = path.withCString { path in
            return zip_open(path, flags.rawValue, &status)
        }

        try zipCheckError(status)
        self.handle = try handle.unwrapped()
    }

    /// Opens the zip archive specified by URL and sets up an instance, used to manipulate the archive.
    ///
    /// - Parameters:
    ///   - url: URL to open
    ///   - flags: open flags, defaults to `[.readOnly]`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_open.html
    public init(url: URL, flags: OpenFlags = [.readOnly]) throws {
        var status: Int32 = ZIP_ER_OK
        let handle: OpaquePointer? = try url.withUnsafeFileSystemRepresentation { path in
            if let path = path {
                return zip_open(path, flags.rawValue, &status)
            } else {
                throw ZipError.unsupportedURL
            }
        }

        try zipCheckError(status)
        self.handle = try handle.unwrapped()
    }

    /// Opens a zip archive encapsulated by the `ZipSource` and sets up an instance, used to manipulate the archive.
    ///
    /// - Parameters:
    ///   - source: source to open
    ///   - flags: open flags, defaults to `[.readOnly]`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_open_from_source.html
    public init(source: ZipSource, flags: OpenFlags = [.readOnly]) throws {
        var error = zip_error()
        self.handle = try zip_open_from_source(source.handle, flags.rawValue, &error).unwrapped(or: error)

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
    /// - Parameters:
    ///   - fd: file descriptor to use
    ///   - flags: open flags, defaults to `[]`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_fdopen.html
    public init(fd: Int32, flags: FDOpenFlags = []) throws {
        var status: Int32 = ZIP_ER_OK
        let handle = zip_fdopen(fd, flags.rawValue, &status)

        try zipCheckError(status)
        self.handle = try handle.unwrapped()
    }

    /// Closes archive and frees the memory allocated for it. Any changes to the archive are not written to disk and discarded.
    /// The `ZipArchive` object is invalidated and must not be used after call to `dsicard()`.
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_discard.html
    public func discard() {
        zip_discard(handle)
        handle = nil
    }

    /// Writes any changes made to archive to disk. If archive contains no files, the file is completely removed (no empty
    /// archive is written). If successful, archive is invalidated, otherwise archive is left unchanged.
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_close.html
    public func close() throws {
        try zipCheckResult(zip_close(handle))
        handle = nil
    }

    // MARK: - Password Handling

    /// Sets the default password used when accessing encrypted files. If password is `nil`, the default password is unset.
    /// If you prefer a different password for single files, pass password to `ZipArchive.open` or `ZipEntry.open` instead.
    /// Usually, however, the same password is used for every file in an zip archive.
    ///
    /// - Parameter password: the password to be used
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_set_default_password.html
    public func setDefaultPassword(_ password: String?) throws {
        if let password = password {
            try password.withCString { password in
                _ = try zipCheckResult(zip_set_default_password(handle, password))
            }
        } else {
            try zipCheckResult(zip_set_default_password(handle, nil))
        }
    }

    // MARK: - Comments

    /// Returns the comment for the entire zip archive.
    ///
    /// - Parameters:
    ///   - decodingStrategy: string decoding strategy, defaults to `.guess`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_get_archive_comment.html
    public func getComment(decodingStrategy: ZipStringDecodingStrategy = .guess, version: Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_get_archive_comment(handle, nil, decodingStrategy.rawValue | version.rawValue)))
    }

    /// Returns the unmodified archive comment as it is in the ZIP archive.
    ///
    /// - Parameter version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_get_archive_comment.html
    public func getRawComment(version: Version = .current) throws -> Data {
        return try Data(cString: zipCheckResult(zip_get_archive_comment(handle, nil, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    /// Sets the comment for the entire zip archive. If `comment` is set to `nil`,
    /// the comment is deleted from the archive.
    ///
    /// - Parameter comment: new comment value
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_set_archive_comment.html
    public func setComment(_ comment: String?) throws {
        if let comment = comment {
            try comment.withCString { comment in
                _ = try zipCheckResult(zip_set_archive_comment(handle, comment, zipCast(strlen(comment))))
            }
        } else {
            try zipCheckResult(zip_set_archive_comment(handle, nil, 0))
        }
    }

    // MARK: - Entry Enumeration

    /// Returns the number of files in archive
    ///
    /// - Parameter version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_get_num_entries.html
    public func getEntryCount(version: Version = .current) throws -> Int {
        return try zipCast(zipCheckResult(zip_get_num_entries(handle, version.rawValue)))
    }

    /// Retrieves archive entry by index
    ///
    /// - Parameter index: index of entry to retrieve
    public func getEntry(index: Int) throws -> ZipEntry {
        return try ZipEntry(archive: self, index: zipCast(index))
    }

    // MARK: - Locate Entry

    ///  Returns the index of the file named `filename` in archive. If archive does not contain a file
    ///  with that name, an error is thrown.
    ///
    /// - Parameters:
    ///   - filename: entry name to locate
    ///   - lookupFlags: lookup options, defaults to `[]`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_name_locate.html
    public func locate(filename: String, lookupFlags: LookupFlags = []) throws -> ZipEntry {
        return try filename.withCString { filename in
            let index = try zipCheckResult(zip_name_locate(handle, filename, lookupFlags.rawValue | ZIP_FL_ENC_UTF_8))
            return try ZipEntry(archive: self, index: zipCast(index))
        }
    }

    // MARK: - Entry Stats

    /// Obtains information about the file named `filename` in archive.
    ///
    /// - Parameters:
    ///   - filename: entry name
    ///   - lookupFlags: lookup options, defaults to `[]`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_stat.html
    public func stat(filename: String, lookupFlags: LookupFlags = [], version: Version = .current) throws -> ZipEntry.Stat {
        var result = ZipEntry.Stat()
        let resultCode = filename.withCString { filename in
            return zip_stat(handle, filename, lookupFlags.rawValue | version.rawValue, &result.stat)
        }

        try zipCheckResult(resultCode)
        return result
    }

    // MARK: - Open Entry for Reading

    /// Opens the file named `filename` in archive using the password given in the password argument.
    ///
    /// - Parameters:
    ///   - filename: entry name to open
    ///   - flags: open flags, defaults to `[]`
    ///   - lookupFlags: lookup options, defaults to `[]`
    ///   - version: archive version to use, defaults to `.current`
    ///   - password: optional password to decrypt the entry
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_fopen.html
    ///   - https://libzip.org/documentation/zip_fopen_encrypted.html
    public func open(filename: String, flags: ZipEntry.OpenFlags = [], lookupFlags: LookupFlags = [], version: Version = .current, password: String? = nil) throws -> ZipEntryReader {
        let entryHandle: OpaquePointer? = filename.withCString { filename in
            if let password = password {
                return password.withCString { password in
                    return zip_fopen_encrypted(handle, filename, flags.rawValue | lookupFlags.rawValue | version.rawValue, password)
                }
            } else {
                return zip_fopen(handle, filename, flags.rawValue | lookupFlags.rawValue | version.rawValue)
            }
        }

        return try ZipEntryReader(zipCheckResult(entryHandle))
    }

    // MARK: - Add/Remove Entries

    /// Adds a directory to a zip archive.
    ///
    /// - Parameter name: the directory's name in the zip archive
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_dir_add.html
    @discardableResult
    public func addDirectory(name: String) throws -> ZipEntry {
        let index: zip_uint64_t = try name.withCString { name in
            return try zipCast(zipCheckResult(zip_dir_add(handle, name, ZIP_FL_ENC_UTF_8)))
        }

        return ZipEntry(archive: self, index: index)
    }

    /// Adds a file to a zip archive.
    ///
    /// - Parameters:
    ///   - name: the file's name in the zip archive
    ///   - source: the data of the file
    ///   - flags: operation flags, defaults to `[]`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_add.html
    @discardableResult
    public func addFile(name: String, source: ZipSource, flags: AddFileFlags = []) throws -> ZipEntry {
        let index: zip_uint64_t = try name.withCString { name in
            return try zipCast(zipCheckResult(zip_file_add(handle, name, source.handle, flags.rawValue | ZIP_FL_ENC_UTF_8)))
        }

        // compensate unbalanced `free` inside `zip_file_add`
        source.keep()
        return ZipEntry(archive: self, index: index)
    }

    // MARK: - Revert Changes

    /// Revert all global changes to the archive.
    /// This reverts changes to the archive comment and global flags.
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_unchange_archive.html
    public func unchangeGlobals() throws {
        try zipCheckResult(zip_unchange_archive(handle))
    }

    /// All changes to files and global information in archive are reverted.
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_unchange_all.html
    public func unchangeAll() throws {
        try zipCheckResult(zip_unchange_all(handle))
    }
}
