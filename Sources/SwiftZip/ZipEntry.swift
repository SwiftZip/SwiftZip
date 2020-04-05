import zip

public struct ZipEntry: ZipErrorContext {
    internal let archive: ZipArchive
    internal let index: zip_uint64_t

    internal init(archive: ZipArchive, index: zip_uint64_t) {
        self.archive = archive
        self.index = index
    }

    // MARK: - Error Context

    internal var error: ZipError? {
        return archive.error
    }

    // MARK: - Name

    public func getName(encoding: ZipArchive.Encoding = .guess, version: ZipArchive.Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_get_name(archive.handle, index, encoding.rawValue | version.rawValue)))
    }

    // MARK: - Attributes

    public struct ExternalAttributes {
        public let operatingSystem: UInt8
        public let attributes: UInt32
    }

    public func getExternalAttributes(version: ZipArchive.Version = .current) throws -> ExternalAttributes {
        var operatingSystem: UInt8 = 0
        var attributes: UInt32 = 0
        try zipCheckResult(zip_file_get_external_attributes(archive.handle, index, version.rawValue, &operatingSystem, &attributes))
        return ExternalAttributes(operatingSystem: operatingSystem, attributes: attributes)
    }

    public func setExternalAttributes(operatingSystem: UInt8, attributes: UInt32) throws {
        try zipCheckResult(zip_file_set_external_attributes(archive.handle, index, 0, operatingSystem, attributes))
    }

    // MARK: - Stat

    public func stat(version: ZipArchive.Version = .current) throws -> zip_stat {
        var result = zip_stat()
        try zipCheckResult(zip_stat_index(archive.handle, index, version.rawValue, &result))
        return result
    }

    // MARK: - Extra Fields

    public struct ExtraFieldFlags: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let central = ExtraFieldFlags(rawValue: ZIP_FL_CENTRAL)
        public static let local = ExtraFieldFlags(rawValue: ZIP_FL_LOCAL)
    }

    public struct ExtraFieldData {
        public let id: UInt16
        public let data: UnsafeRawBufferPointer
    }

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

    public func getComment(encoding: ZipArchive.Encoding = .guess, version: ZipArchive.Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_file_get_comment(archive.handle, index, nil, encoding.rawValue | version.rawValue)))
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

    public struct OpenFlags: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let compressed = OpenFlags(rawValue: ZIP_FL_COMPRESSED)
    }

    public func open(flags: OpenFlags = [], version: ZipArchive.Version = .current, password: String? = nil) throws -> ZipEntryFile {
        let handle: OpaquePointer?
        if let password = password {
            handle = password.withCString { password in
                return zip_fopen_index_encrypted(archive.handle, index, flags.rawValue | version.rawValue, password)
            }
        } else {
            handle = zip_fopen_index(archive.handle, index, flags.rawValue)
        }

        return try ZipEntryFile(zipCheckResult(handle))
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

    public struct CompressionMethod: RawRepresentable {
        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let `default` = CompressionMethod(rawValue: ZIP_CM_DEFAULT)
        public static let store = CompressionMethod(rawValue: ZIP_CM_STORE)
        public static let deflate = CompressionMethod(rawValue: ZIP_CM_DEFLATE)
    }

    public struct CompressionFlags: RawRepresentable {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let `default` = CompressionFlags(rawValue: 0)
        public static let fastest = CompressionFlags(rawValue: 1)
        public static let best = CompressionFlags(rawValue: 9)
    }

    public func setCompression(method: CompressionMethod = .default, flags: CompressionFlags = .default) throws {
        try zipCheckResult(zip_set_file_compression(archive.handle, index, method.rawValue, flags.rawValue))
    }

    // MARK: - Encryption

    public struct EncryptionMethod: RawRepresentable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public static let none = EncryptionMethod(rawValue: UInt16(ZIP_EM_NONE))
        public static let aes128 = EncryptionMethod(rawValue: UInt16(ZIP_EM_AES_128))
        public static let aes192 = EncryptionMethod(rawValue: UInt16(ZIP_EM_AES_192))
        public static let aes256 = EncryptionMethod(rawValue: UInt16(ZIP_EM_AES_256))
    }

    public func setEncryption(method: EncryptionMethod) throws {
        try zipCheckResult(zip_file_set_encryption(archive.handle, index, method.rawValue, nil))
    }

    public func setEncryption(method: EncryptionMethod, password: String) throws {
        try password.withCString { password in
            _ = try zipCheckResult(zip_file_set_encryption(archive.handle, index, method.rawValue, password))
        }
    }

    // MARK: - Revert Changes

    public func unchange() throws {
        try zipCheckResult(zip_unchange(archive.handle, index))
    }
}
