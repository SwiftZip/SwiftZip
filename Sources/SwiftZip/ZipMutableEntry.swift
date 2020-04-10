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

/// A read-write accessor for an entry in the archive.
public final class ZipMutableEntry: ZipEntry { }

// MARK: - Attributes

extension ZipMutableEntry {
    /// Sets the operating system and external attributes for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_set_external_attributes](https://libzip.org/documentation/zip_file_set_external_attributes.html)
    ///
    /// - Parameters:
    ///   - operatingSystem: operating system value
    ///   - attributes: external attributes to set
    public func setExternalAttributes(operatingSystem: ZipOperatingSystem, attributes: UInt32) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, entry, 0, operatingSystem.rawValue, attributes))
    }

    /// Sets the operating system and POSIX attributes to be set as external attributes for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_set_external_attributes](https://libzip.org/documentation/zip_file_set_external_attributes.html)
    ///
    /// - Parameters:
    ///   - operatingSystem: operating system value, defaults to `.unix`
    ///   - posixAttributes: POSIX attributes to be set
    public func setExternalAttributes(operatingSystem: ZipOperatingSystem = .unix, posixAttributes: mode_t) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, entry, 0, operatingSystem.rawValue, UInt32(posixAttributes) << 16))
    }
}

// MARK: - Extra fields

extension ZipMutableEntry {
    /// Sets the extra field with ID (two-byte signature) `id` and index `index` for the file in the zip archive.
    /// The extra field's data will be set to `data`. If a new entry shall be appended, set `index` to `nil`.
    ///
    /// Please note that the extra field IDs 0x0001 (ZIP64 extension), 0x6375 (Infozip UTF-8 comment),
    /// and 0x7075 (Infozip UTF-8 file name) can not be set using `setExtraField` since they are set
    /// by `libzip(3)` automatically when needed.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_field_set](https://libzip.org/documentation/zip_file_extra_field_set.html)
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to set
    ///   - data: new field data
    ///   - flags: field lookup flags
    public func setExtraField(id: UInt16, index: Int?, data: Data, flags: ExtraFieldFlags) throws {
        let index = index ?? Int(ZIP_EXTRA_FIELD_NEW)
        try data.withUnsafeBytes { data in
            _ = try zipCheckResult(zip_file_extra_field_set(archive.handle, entry, id, zipCast(index), data.bindMemory(to: zip_uint8_t.self).baseAddress, zipCast(data.count), flags.rawValue))
        }
    }

    /// Deletes the extra field with index `index` for the file in the zip archive.
    /// If `index` is `nil`, then all extra fields will be deleted.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_field_delete](https://libzip.org/documentation/zip_file_extra_field_delete.html)
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to delete
    ///   - flags: field lookup flags
    public func deleteExtraField(index: Int?, flags: ExtraFieldFlags) throws {
        let index = index ?? Int(ZIP_EXTRA_FIELD_ALL)
        try zipCheckResult(zip_file_extra_field_delete(archive.handle, entry, zipCast(index), flags.rawValue))
    }

    /// Deletes the `index`-s extra field with a specified field ID for the file in the zip archive.
    /// If `index` is `nil`, then all extra fields with the specified ID will be deleted.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_field_delete_by_id](https://libzip.org/documentation/zip_file_extra_field_delete_by_id.html)
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to delete
    ///   - flags: field lookup flags
    public func deleteExtraField(id: UInt16, index: Int?, flags: ExtraFieldFlags) throws {
        let index = index ?? Int(ZIP_EXTRA_FIELD_ALL)
        try zipCheckResult(zip_file_extra_field_delete(archive.handle, entry, zipCast(index), flags.rawValue))
    }
}

// MARK: - Comments

extension ZipMutableEntry {
    /// Sets the comment for the file in the zip archive.If `comment` is set to `nil`,
    /// the comment is deleted from the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_set_comment](https://libzip.org/documentation/zip_file_set_comment.html)
    ///
    /// - Parameters:
    ///   - comment: new comment string
    public func setComment(_ comment: String?) throws {
        if let comment = comment {
            try comment.withCString { comment in
                _ = try zipCheckResult(zip_file_set_comment(archive.handle, entry, comment, zipCast(strlen(comment)), ZIP_FL_ENC_UTF_8))
            }
        } else {
            try zipCheckResult(zip_file_set_comment(archive.handle, entry, nil, 0, 0))
        }
    }
}

// MARK: - Entry properties

extension ZipMutableEntry {
    /// Sets the last modification time (mtime) for the file in the zip archive to `date`.
    ///
    /// - SeeAlso:
    ///   - [zip_file_set_mtime](https://libzip.org/documentation/zip_file_set_mtime.html)
    ///
    /// - Parameters:
    ///   - date: new file modification time
    public func setModifiedDate(_ date: Date) throws {
        try zipCheckResult(zip_file_set_mtime(archive.handle, entry, zipCast(Int(date.timeIntervalSince1970)), 0))
    }
}

// MARK: - Compression

extension ZipMutableEntry {
    /// Sets the compression method for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_set_file_compression](https://libzip.org/documentation/zip_set_file_compression.html)
    ///
    /// - Parameters:
    ///   - method: compression method to set
    ///   - flags: compression method specific flags
    public func setCompression(method: CompressionMethod = .default, flags: CompressionFlags = .default) throws {
        try zipCheckResult(zip_set_file_compression(archive.handle, entry, method.rawValue, flags.rawValue))
    }
}

// MARK: - Encryption

extension ZipMutableEntry {
    /// Sets the encryption method and password for the file in the zip archive.
    /// If `password` is `nil`, the default password provided by `ZipArchive.setDefaultPassword` is used.
    ///
    /// - SeeAlso:
    ///   - [zip_file_set_encryption](https://libzip.org/documentation/zip_file_set_encryption.html)
    ///
    /// - Parameters:
    ///   - method: encryption method to set
    ///   - password: encryption password
    public func setEncryption(method: EncryptionMethod, password: String? = nil) throws {
        if let password = password {
            try password.withCString { password in
                _ = try zipCheckResult(zip_file_set_encryption(archive.handle, entry, method.rawValue, password))
            }
        } else {
            try zipCheckResult(zip_file_set_encryption(archive.handle, entry, method.rawValue, nil))
        }
    }
}

// MARK: - Deletion

extension ZipMutableEntry {
    /// Marks the file the archive as deleted.
    ///
    /// - SeeAlso:
    ///   - [zip_delete](https://libzip.org/documentation/zip_delete.html)
    public func delete() throws {
        try zipCheckResult(zip_delete(archive.handle, entry))
    }
}

// MARK: - Revert changes

extension ZipMutableEntry {
    /// Changes to the file are reverted.
    ///
    /// - SeeAlso:
    ///   - [zip_unchange](https://libzip.org/documentation/zip_unchange.html)
    public func unchange() throws {
        try zipCheckResult(zip_unchange(archive.handle, entry))
    }
}
