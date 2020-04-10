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

/// A read-only accessor for an entry in the archive.
public class ZipEntry: ZipErrorContext {
    internal let archive: ZipArchive
    internal let entry: zip_uint64_t
    private let version: ZipArchive.Version

    internal init(archive: ZipArchive, entry: zip_uint64_t, version: ZipArchive.Version) {
        self.archive = archive
        self.entry = entry
        self.version = version
    }

    // MARK: - Error context

    internal final var lastError: zip_error_t? {
        return archive.lastError
    }

    internal final func clearError() {
        archive.clearError()
    }

    // MARK: - Name

    /// Returns the name of the file in the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_get_name](https://libzip.org/documentation/zip_get_name.html)
    ///
    /// - Parameters:
    ///   - decodingStrategy: string decoding strategy, defaults to `.guess`
    public final func getName(decodingStrategy: ZipStringDecodingStrategy = .guess) throws -> String {
        return try String(cString: zipCheckResult(zip_get_name(archive.handle, entry, decodingStrategy.rawValue | version.rawValue)))
    }

    /// Returns the unmodified name of the as it is in the ZIP archive
    ///
    /// - SeeAlso:
    ///   - [zip_get_name](https://libzip.org/documentation/zip_get_name.html)
    public final func getRawName() throws -> Data {
        return try Data(cString: zipCheckResult(zip_get_name(archive.handle, entry, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    // MARK: - Attributes

    /// Returns the operating system and external attributes for the file in the zip archive.
    /// The external attributes usually contain the operating system-specific file permissions.
    ///
    /// - SeeAlso:
    ///   - [zip_file_get_external_attributes](https://libzip.org/documentation/zip_file_get_external_attributes.html)
    public final func getExternalAttributes() throws -> ExternalAttributes {
        var operatingSystem: UInt8 = 0
        var attributes: UInt32 = 0
        try zipCheckResult(zip_file_get_external_attributes(archive.handle, entry, version.rawValue, &operatingSystem, &attributes))
        return ExternalAttributes(operatingSystem: ZipOperatingSystem(rawValue: operatingSystem), attributes: attributes)
    }

    // MARK: - Stat

    /// Obtains information about the file in archive.
    ///
    /// - SeeAlso:
    ///   - [zip_stat_index](https://libzip.org/documentation/zip_stat_index.html)
    public final func stat() throws -> Stat {
        var result = Stat()
        try zipCheckResult(zip_stat_index(archive.handle, entry, version.rawValue, &result.stat))
        return result
    }

    // MARK: - Extra fields

    /// Counts the extra fields for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_fields_count](https://libzip.org/documentation/zip_file_extra_fields_count.html)
    ///
    /// - Parameters:
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    public final func getExtraFieldsCount(flags: ExtraFieldFlags = [.local, .central]) throws -> Int {
        return try zipCast(zipCheckResult(zip_file_extra_fields_count(archive.handle, entry, flags.rawValue | version.rawValue)))
    }

    /// Counts the extra fields with ID (two-byte signature) `id` for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_fields_count_by_id](https://libzip.org/documentation/zip_file_extra_fields_count_by_id.html)
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    public final func getExtraFieldsCount(id: UInt16, flags: ExtraFieldFlags = [.local, .central]) throws -> Int {
        return try zipCast(zipCheckResult(zip_file_extra_fields_count_by_id(archive.handle, entry, id, flags.rawValue | version.rawValue)))
    }

    /// Returns the extra field with index `index` for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_field_get](https://libzip.org/documentation/zip_file_extra_field_get.html)
    ///
    /// - Parameters:
    ///   - index: field index to retrieve
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    public final func getExtraField(index: Int, flags: ExtraFieldFlags = [.local, .central]) throws -> (id: UInt16, data: Data) {
        var fieldID: UInt16 = 0
        var fieldLength: UInt16 = 0
        let fieldData = try zipCheckResult(zip_file_extra_field_get(archive.handle, entry, zipCast(index), &fieldID, &fieldLength, flags.rawValue | version.rawValue))
        return try (id: fieldID, data: Data(bytes: fieldData, count: zipCast(fieldLength)))
    }

    /// Returns the `index`-s extra field with a specified field ID for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_extra_field_get_by_id](https://libzip.org/documentation/zip_file_extra_field_get_by_id.html)
    ///
    /// - Parameters:
    ///   - id: field ID (two-byte signature) filter
    ///   - index: field index to retrieve
    ///   - flags: field lookup flags, defaults to `[.local, .central]`
    public final func getExtraField(id: UInt16, index: Int, flags: ExtraFieldFlags = [.local, .central]) throws -> Data {
        var fieldLength: UInt16 = 0
        let fieldData = try zipCheckResult(zip_file_extra_field_get_by_id(archive.handle, entry, id, zipCast(index), &fieldLength, flags.rawValue | version.rawValue))
        return try Data(bytes: fieldData, count: zipCast(fieldLength))
    }

    // MARK: - Comments

    /// Returns the comment for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_get_comment](https://libzip.org/documentation/zip_file_get_comment.html)
    ///
    /// - Parameters:
    ///   - decodingStrategy: string decoding strategy, defaults to `.guess`
    public final func getComment(decodingStrategy: ZipStringDecodingStrategy = .guess) throws -> String {
        return try String(cString: zipCheckResult(zip_file_get_comment(archive.handle, entry, nil, decodingStrategy.rawValue | version.rawValue)))
    }

    /// Returns the unmodified comment for the file as it is in the ZIP archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_get_comment](https://libzip.org/documentation/zip_file_get_comment.html)
    public final func getRawComment() throws -> Data {
        return try Data(cString: zipCheckResult(zip_file_get_comment(archive.handle, entry, nil, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    // MARK: - Open for reading

    /// Opens the file using the password given in the password argument.
    ///
    /// - SeeAlso:
    ///   - [zip_fopen_index](https://libzip.org/documentation/zip_fopen_index.html)
    ///   - [zip_fopen_index_encrypted](https://libzip.org/documentation/zip_fopen_index_encrypted.html)
    ///
    /// - Parameters:
    ///   - flags: open flags, defaults to `[]`
    ///   - password: optional password to decrypt the entry
    public final func open(flags: OpenFlags = [], password: String? = nil) throws -> ZipEntryReader {
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
}
