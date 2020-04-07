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
    internal let index: zip_uint64_t

    // MARK: - Error Context

    internal var error: ZipError? {
        return archive.error
    }

    // MARK: - Name

    public func getName(decodingStrategy: ZipStringDecodingStrategy = .guess, version: ZipArchive.Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_get_name(archive.handle, index, decodingStrategy.rawValue | version.rawValue)))
    }

    public func getRawName(version: ZipArchive.Version = .current) throws -> Data {
        return try Data(cString: zipCheckResult(zip_get_name(archive.handle, index, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    // MARK: - Attributes

    public func getExternalAttributes(version: ZipArchive.Version = .current) throws -> ExternalAttributes {
        var operatingSystem: UInt8 = 0
        var attributes: UInt32 = 0
        try zipCheckResult(zip_file_get_external_attributes(archive.handle, index, version.rawValue, &operatingSystem, &attributes))
        return ExternalAttributes(operatingSystem: ExternalAttributes.OperatingSystem(rawValue: operatingSystem), attributes: attributes)
    }

    public func setExternalAttributes(operatingSystem: ExternalAttributes.OperatingSystem, attributes: UInt32) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, index, 0, operatingSystem.rawValue, attributes))
    }

    public func setExternalAttributes(operatingSystem: ExternalAttributes.OperatingSystem = .unix, posixAttributes: mode_t) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, index, 0, operatingSystem.rawValue, UInt32(posixAttributes) << 16))
    }

    // MARK: - Stat

    public func stat(version: ZipArchive.Version = .current) throws -> Stat {
        var result = Stat()
        try zipCheckResult(zip_stat_index(archive.handle, index, version.rawValue, &result.stat))
        return result
    }

    // MARK: - Extra Fields

    public func getExtraFieldsCount(id: UInt16?, flags: ExtraFieldFlags, version: ZipArchive.Version = .current) throws -> Int {
        if let id = id {
            return try zipCast(zipCheckResult(zip_file_extra_fields_count_by_id(archive.handle, index, id, flags.rawValue | version.rawValue)))
        } else {
            return try zipCast(zipCheckResult(zip_file_extra_fields_count(archive.handle, index, flags.rawValue | version.rawValue)))
        }
    }

    public func getExtraField(id: UInt16?, fieldIndex: Int, flags: ExtraFieldFlags, version: ZipArchive.Version = .current) throws -> ExtraFieldData {
        var fieldID: UInt16 = 0
        var fieldLength: UInt16 = 0
        let fieldData: UnsafePointer<zip_uint8_t>

        if let id = id {
            fieldID = id
            fieldData = try zipCheckResult(zip_file_extra_field_get_by_id(archive.handle, index, id, zipCast(fieldIndex), &fieldLength, flags.rawValue | version.rawValue))
        } else {
            fieldData = try zipCheckResult(zip_file_extra_field_get(archive.handle, index, zipCast(fieldIndex), &fieldID, &fieldLength, flags.rawValue | version.rawValue))
        }

        return try ExtraFieldData(id: fieldLength, data: UnsafeRawBufferPointer(start: fieldData, count: zipCast(fieldLength)))
    }

    public func setExtraField(id: UInt16, fieldIndex: Int, data: UnsafeRawBufferPointer, flags: ExtraFieldFlags) throws {
        try zipCheckResult(zip_file_extra_field_set(archive.handle, index, id, zipCast(fieldIndex), data.bindMemory(to: zip_uint8_t.self).baseAddress, zipCast(data.count), flags.rawValue))
    }

    public func deleteExtraField(id: UInt16?, fieldIndex: Int, flags: ExtraFieldFlags) throws {
        if let id = id {
            try zipCheckResult(zip_file_extra_field_delete_by_id(archive.handle, index, id, zipCast(fieldIndex), flags.rawValue))
        } else {
            try zipCheckResult(zip_file_extra_field_delete(archive.handle, index, zipCast(fieldIndex), flags.rawValue))
        }
    }

    // MARK: - Comments

    public func getComment(decodingStrategy: ZipStringDecodingStrategy = .guess, version: ZipArchive.Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_file_get_comment(archive.handle, index, nil, decodingStrategy.rawValue | version.rawValue)))
    }

    public func getRawComment(version: ZipArchive.Version = .current) throws -> Data {
        return try Data(cString: zipCheckResult(zip_file_get_comment(archive.handle, index, nil, ZIP_FL_ENC_RAW | version.rawValue)))
    }

    public func setComment(comment: String) throws {
        try comment.withCString { comment in
            _ = try zipCheckResult(zip_file_set_comment(archive.handle, index, comment, zipCast(strlen(comment)), ZIP_FL_ENC_UTF_8))
        }
    }

    public func deleteComment() throws {
        try zipCheckResult(zip_file_set_comment(archive.handle, index, nil, 0, 0))
    }

    // MARK: - Open for Reading

    public func open(flags: OpenFlags = [], version: ZipArchive.Version = .current, password: String? = nil) throws -> ZipEntryReader {
        let handle: OpaquePointer?
        if let password = password {
            handle = password.withCString { password in
                return zip_fopen_index_encrypted(archive.handle, index, flags.rawValue | version.rawValue, password)
            }
        } else {
            handle = zip_fopen_index(archive.handle, index, flags.rawValue)
        }

        return try ZipEntryReader(zipCheckResult(handle))
    }

    // MARK: - Add/Remove Entries

    public func replaceFile(source: ZipSource) throws {
        try zipCheckResult(zip_file_replace(archive.handle, index, source.handle, ZIP_FL_ENC_UTF_8))

        // compensate unbalanced `free` inside `zip_file_replace`
        source.keep()
    }

    public func rename(name: String) throws {
        try name.withCString { name in
            _ = try zipCheckResult(zip_file_rename(archive.handle, index, name, ZIP_FL_ENC_UTF_8))
        }
    }

    public func setModified(time: time_t) throws {
        try zipCheckResult(zip_file_set_mtime(archive.handle, index, time, 0))
    }

    // MARK: - Compression

    public func setCompression(method: ZipCompressionMethod = .default, flags: ZipCompressionFlags = .default) throws {
        try zipCheckResult(zip_set_file_compression(archive.handle, index, method.rawValue, flags.rawValue))
    }

    // MARK: - Encryption

    public func setEncryption(method: ZipEncryptionMethod) throws {
        try zipCheckResult(zip_file_set_encryption(archive.handle, index, method.rawValue, nil))
    }

    public func setEncryption(method: ZipEncryptionMethod, password: String) throws {
        try password.withCString { password in
            _ = try zipCheckResult(zip_file_set_encryption(archive.handle, index, method.rawValue, password))
        }
    }

    // MARK: - Revert Changes

    public func unchange() throws {
        try zipCheckResult(zip_unchange(archive.handle, index))
    }
}
