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

public struct ZipEntry: ZipErrorContext {
    internal let archive: ZipArchive
    internal let entry: zip_uint64_t

    // MARK: - Error Context

    internal var error: zip_error_t? {
        return archive.error
    }

    internal func clearError() {
        archive.clearError()
    }

    // MARK: - Name

    /// Returns the name of the file in the archive.
    ///
    /// - Parameters:
    ///   - decodingStrategy: string decoding strategy, defaults to `.guess`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_get_name.html
    public func getName(decodingStrategy: ZipStringDecodingStrategy = .guess, version: ZipArchive.Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_get_name(archive.handle, entry, decodingStrategy.rawValue | version.rawValue)))
    }

    /// Returns the unmodified name of the as it is in the ZIP archive
    ///
    /// - Parameter version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_get_name.html
    public func getRawName(version: ZipArchive.Version = .current) throws -> Data {
        return try Data(cString: zipCheckResult(zip_get_name(archive.handle, entry, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    // MARK: - Attributes

    /// Returns the operating system and external attributes for the file in the zip archive.
    /// The external attributes usually contain the operating system-specific file permissions.
    ///
    /// - Parameter version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_get_external_attributes.html
    public func getExternalAttributes(version: ZipArchive.Version = .current) throws -> ExternalAttributes {
        var operatingSystem: UInt8 = 0
        var attributes: UInt32 = 0
        try zipCheckResult(zip_file_get_external_attributes(archive.handle, entry, version.rawValue, &operatingSystem, &attributes))
        return ExternalAttributes(operatingSystem: ZipOperatingSystem(rawValue: operatingSystem), attributes: attributes)
    }

    /// Sets the operating system and external attributes for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - operatingSystem: operating system value
    ///   - attributes: external attributes to set
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_set_external_attributes.html
    public func setExternalAttributes(operatingSystem: ZipOperatingSystem, attributes: UInt32) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, entry, 0, operatingSystem.rawValue, attributes))
    }

    /// Sets the operating system and POSIX attributes to be set as external attributes for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - operatingSystem: operating system value, defaults to `.unix`
    ///   - posixAttributes: POSIX attributes to be set
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_set_external_attributes.html
    public func setExternalAttributes(operatingSystem: ZipOperatingSystem = .unix, posixAttributes: mode_t) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, entry, 0, operatingSystem.rawValue, UInt32(posixAttributes) << 16))
    }

    // MARK: - Stat

    /// Obtains information about the file in archive.
    ///
    /// - Parameter version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_stat_index.html
    public func stat(version: ZipArchive.Version = .current) throws -> Stat {
        var result = Stat()
        try zipCheckResult(zip_stat_index(archive.handle, entry, version.rawValue, &result.stat))
        return result
    }

    // MARK: - Extra Fields

    /// Counts the extra fields for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_fields_count.html
    public func getExtraFieldsCount(flags: ExtraFieldFlags = [.local, .central], version: ZipArchive.Version = .current) throws -> Int {
        return try zipCast(zipCheckResult(zip_file_extra_fields_count(archive.handle, entry, flags.rawValue | version.rawValue)))
    }

    /// Counts the extra fields with ID (two-byte signature) `id` for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_fields_count_by_id.html
    public func getExtraFieldsCount(id: UInt16, flags: ExtraFieldFlags = [.local, .central], version: ZipArchive.Version = .current) throws -> Int {
        return try zipCast(zipCheckResult(zip_file_extra_fields_count_by_id(archive.handle, entry, id, flags.rawValue | version.rawValue)))
    }

    /// Returns the extra field with index `index` for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - index: field index to retrieve
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_field_get.html
    public func getExtraField(index: Int, flags: ExtraFieldFlags = [.local, .central], version: ZipArchive.Version = .current) throws -> (id: UInt16, data: Data) {
        var fieldID: UInt16 = 0
        var fieldLength: UInt16 = 0
        let fieldData = try zipCheckResult(zip_file_extra_field_get(archive.handle, entry, zipCast(index), &fieldID, &fieldLength, flags.rawValue | version.rawValue))
        return try (id: fieldID, data: Data(bytes: fieldData, count: zipCast(fieldLength)))
    }

    /// Returns the `index`-s extra field with a specified field ID for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to retrieve
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_field_get_by_id.html
    public func getExtraField(id: UInt16, index: Int, flags: ExtraFieldFlags = [.local, .central], version: ZipArchive.Version = .current) throws -> Data {
        var fieldLength: UInt16 = 0
        let fieldData = try zipCheckResult(zip_file_extra_field_get_by_id(archive.handle, entry, id, zipCast(index), &fieldLength, flags.rawValue | version.rawValue))
        return try Data(bytes: fieldData, count: zipCast(fieldLength))
    }

    /// Sets the extra field with ID (two-byte signature) `id` and index `index` for the file in the zip archive.
    /// The extra field's data will be set to `data`. If a new entry shall be appended, set `index` to `nil`.
    ///
    /// Please note that the extra field IDs 0x0001 (ZIP64 extension), 0x6375 (Infozip UTF-8 comment),
    /// and 0x7075 (Infozip UTF-8 file name) can not be set using `setExtraField` since they are set
    /// by `libzip(3)` automatically when needed.
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to set
    ///   - data: new field data
    ///   - flags: field lookup flags
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_field_set.html
    public func setExtraField(id: UInt16, index: Int?, data: Data, flags: ExtraFieldFlags) throws {
        let index = index ?? Int(ZIP_EXTRA_FIELD_NEW)
        try data.withUnsafeBytes { data in
            _ = try zipCheckResult(zip_file_extra_field_set(archive.handle, entry, id, zipCast(index), data.bindMemory(to: zip_uint8_t.self).baseAddress, zipCast(data.count), flags.rawValue))
        }
    }

    /// Deletes the extra field with index `index` for the file in the zip archive.
    /// If `index` is `nil`, then all extra fields will be deleted.
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to delete
    ///   - flags: field lookup flags
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_field_delete.html
    public func deleteExtraField(index: Int?, flags: ExtraFieldFlags) throws {
        let index = index ?? Int(ZIP_EXTRA_FIELD_ALL)
        try zipCheckResult(zip_file_extra_field_delete(archive.handle, entry, zipCast(index), flags.rawValue))
    }

    /// Deletes the `index`-s extra field with a specified field ID for the file in the zip archive.
    /// If `index` is `nil`, then all extra fields with the specified ID will be deleted.
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to delete
    ///   - flags: field lookup flags
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_extra_field_delete_by_id.html
    public func deleteExtraField(id: UInt16, index: Int?, flags: ExtraFieldFlags) throws {
        let index = index ?? Int(ZIP_EXTRA_FIELD_ALL)
        try zipCheckResult(zip_file_extra_field_delete(archive.handle, entry, zipCast(index), flags.rawValue))
    }

    // MARK: - Comments

    /// Returns the comment for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - decodingStrategy: string decoding strategy, defaults to `.guess`
    ///   - version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_get_comment.html
    public func getComment(decodingStrategy: ZipStringDecodingStrategy = .guess, version: ZipArchive.Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_file_get_comment(archive.handle, entry, nil, decodingStrategy.rawValue | version.rawValue)))
    }

    /// Returns the unmodified comment for the file as it is in the ZIP archive.
    ///
    /// - Parameter version: archive version to use, defaults to `.current`
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_get_comment.html
    public func getRawComment(version: ZipArchive.Version = .current) throws -> Data {
        return try Data(cString: zipCheckResult(zip_file_get_comment(archive.handle, entry, nil, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    /// Sets the comment for the file in the zip archive.If `comment` is set to `nil`,
    /// the comment is deleted from the archive.
    ///
    /// - Parameter comment: new comment string
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_set_comment.html
    public func setComment(_ comment: String?) throws {
        if let comment = comment {
            try comment.withCString { comment in
                _ = try zipCheckResult(zip_file_set_comment(archive.handle, entry, comment, zipCast(strlen(comment)), ZIP_FL_ENC_UTF_8))
            }
        } else {
            try zipCheckResult(zip_file_set_comment(archive.handle, entry, nil, 0, 0))
        }
    }

    // MARK: - Open for Reading

    /// Opens the file using the password given in the password argument.
    ///
    /// - Parameters:
    ///   - flags: open flags, defaults to `[]`
    ///   - version: archive version to use, defaults to `.current`
    ///   - password: optional password to decrypt the entry
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_fopen_index.html
    ///   - https://libzip.org/documentation/zip_fopen_index_encrypted.html
    public func open(flags: OpenFlags = [], version: ZipArchive.Version = .current, password: String? = nil) throws -> ZipEntryReader {
        let handle: OpaquePointer?
        if let password = password {
            handle = password.withCString { password in
                return zip_fopen_index_encrypted(archive.handle, entry, flags.rawValue | version.rawValue, password)
            }
        } else {
            handle = zip_fopen_index(archive.handle, entry, flags.rawValue)
        }

        return try ZipEntryReader(zipCheckResult(handle))
    }

    // MARK: - Add/Rename Entries

    /// Replaces an existing file in a zip archive.
    ///
    /// - Parameters:
    ///   - source: new data for the file
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_replace.html
    public func replaceFile(source: ZipSource) throws {
        try zipCheckResult(zip_file_replace(archive.handle, entry, source.handle, ZIP_FL_ENC_UTF_8))

        // compensate unbalanced `free` inside `zip_file_replace`
        source.keep()
    }

    /// The file in the zip archive is renamed to `name`.
    ///
    /// - Parameter name: new name of the file
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_rename.html
    public func rename(to name: String) throws {
        try name.withCString { name in
            _ = try zipCheckResult(zip_file_rename(archive.handle, entry, name, ZIP_FL_ENC_UTF_8))
        }
    }

    // MARK: - Entry Properties

    /// Sets the last modification time (mtime) for the file in the zip archive to `date`.
    ///
    /// - Parameter date: new file modification time
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_set_mtime.html
    public func setModifiedDate(_ date: Date) throws {
        try zipCheckResult(zip_file_set_mtime(archive.handle, entry, zipCast(Int(date.timeIntervalSince1970)), 0))
    }

    // MARK: - Compression

    /// Sets the compression method for the file in the zip archive.
    ///
    /// - Parameters:
    ///   - method: compression method to set
    ///   - flags: compression method specific flags
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_set_file_compression.html
    public func setCompression(method: ZipCompressionMethod = .default, flags: ZipCompressionFlags = .default) throws {
        try zipCheckResult(zip_set_file_compression(archive.handle, entry, method.rawValue, flags.rawValue))
    }

    // MARK: - Encryption

    /// Sets the encryption method and password for the file in the zip archive.
    /// If `password` is `nil`, the default password provided by `ZipArchive.setDefaultPassword` is used.
    ///
    /// - Parameters:
    ///   - method: encryption method to set
    ///   - password: encryption password
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_file_set_encryption.html
    public func setEncryption(method: ZipEncryptionMethod, password: String? = nil) throws {
        if let password = password {
            try password.withCString { password in
                _ = try zipCheckResult(zip_file_set_encryption(archive.handle, entry, method.rawValue, password))
            }
        } else {
            try zipCheckResult(zip_file_set_encryption(archive.handle, entry, method.rawValue, nil))
        }
    }

    // MARK: - Deletion

    /// Marks the file the archive as deleted.
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_delete.html
    public func delete() throws {
        try zipCheckResult(zip_delete(archive.handle, entry))
    }

    // MARK: - Revert Changes

    /// Changes to the file are reverted.
    ///
    /// - See also:
    ///   - https://libzip.org/documentation/zip_unchange.html
    public func unchange() throws {
        try zipCheckResult(zip_unchange(archive.handle, entry))
    }
}
