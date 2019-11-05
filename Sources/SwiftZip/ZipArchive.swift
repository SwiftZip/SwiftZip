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

    // MARK: - Common Flags

    public struct Version: RawRepresentable {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let unchanged = Version(rawValue: ZIP_FL_UNCHANGED)
        public static let current = Version(rawValue: 0)
    }

    public struct Encoding: RawRepresentable {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let guess = Encoding(rawValue: ZIP_FL_ENC_GUESS)
        public static let strict = Encoding(rawValue: ZIP_FL_ENC_STRICT)
    }

    // MARK: - Open/Close Archive

    public struct OpenFlags: OptionSet {
        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let checkConsistency = OpenFlags(rawValue: ZIP_CHECKCONS)
        public static let create = OpenFlags(rawValue: ZIP_CREATE)
        public static let exclusive = OpenFlags(rawValue: ZIP_EXCL)
        public static let truncate = OpenFlags(rawValue: ZIP_TRUNCATE)
        public static let readOnly = OpenFlags(rawValue: ZIP_RDONLY)
    }

    public init(path: String, flags: OpenFlags = [.readOnly]) throws {
        var status: Int32 = ZIP_ER_OK
        let handle = path.withCString { path in
            return zip_open(path, flags.rawValue, &status)
        }

        try zipCheckError(status)
        self.handle = try handle.unwrapped()
    }

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

    public init(source: ZipSource, flags: OpenFlags = [.readOnly]) throws {
        var error = zip_error()
        self.handle = try zip_open_from_source(source.handle, flags.rawValue, &error).unwrapped(or: error)

        // compensate unbalanced `free` inside `zip_open_from_source`
        source.keep()
    }

    public struct FDOpenFlags: OptionSet {
        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let checkConsistency = FDOpenFlags(rawValue: ZIP_CHECKCONS)
    }

    public init(fd: Int32, flags: FDOpenFlags = []) throws {
        var status: Int32 = ZIP_ER_OK
        let handle = zip_fdopen(fd, flags.rawValue, &status)

        try zipCheckError(status)
        self.handle = try handle.unwrapped()
    }

    public func close(discard: Bool = false) throws {
        if discard {
            zip_discard(handle)
        } else {
            zip_close(handle)
        }

        handle = nil
    }

    // MARK: - Password Handling

    public func setDefaultPassword(_ password: String) throws {
        try password.withCString { password in
            _ = try zipCheckResult(zip_set_default_password(handle, password))
        }
    }

    // MARK: - Comments

    public func getComment(encoding: Encoding = .guess, version: Version = .current) throws -> String {
        return try String(cString: zipCheckResult(zip_get_archive_comment(handle, nil, encoding.rawValue | version.rawValue)))
    }

    public func setComment(comment: String) throws {
        try comment.withCString { comment in
            _ = try zipCheckResult(zip_set_archive_comment(handle, comment, zipCast(strlen(comment))))
        }
    }

    public func deleteComment() throws {
        try zipCheckResult(zip_set_archive_comment(handle, nil, 0))
    }

    // MARK: - Entry Count

    public func getEntryCount(version: Version = .current) throws -> Int {
        return try zipCast(zipCheckResult(zip_get_num_entries(handle, version.rawValue)))
    }

    public func getEntry(index: Int) throws -> ZipEntry {
        return try ZipEntry(archive: self, index: zipCast(index))
    }

    // MARK: - Locate Entry

    public struct LocateFlags: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let caseInsensitive = LocateFlags(rawValue: ZIP_FL_NOCASE)
        public static let ignoreDirectory = LocateFlags(rawValue: ZIP_FL_NODIR)
    }

    public func locate(filename: String, flags: LocateFlags = []) throws -> ZipEntry {
        return try filename.withCString { filename in
            let index = try zipCheckResult(zip_name_locate(handle, filename, flags.rawValue | ZIP_FL_ENC_UTF_8))
            return try ZipEntry(archive: self, index: zipCast(index))
        }
    }

    // MARK: - Entry Stats

    public func stat(filename: String, version: Version = .current) throws -> zip_stat {
        var result = zip_stat()
        let resultCode = filename.withCString { filename in
            return zip_stat(handle, filename, version.rawValue, &result)
        }

        try zipCheckResult(resultCode)
        return result
    }

    // MARK: - Open Entry for Reading

    public func open(filename: String, flags: ZipEntry.OpenFlags = [], password: String? = nil) throws -> ZipEntryFile {
        let entryHandle: OpaquePointer? = filename.withCString { filename in
            if let password = password {
                return password.withCString { password in
                    return zip_fopen_encrypted(handle, filename, flags.rawValue, password)
                }
            } else {
                return zip_fopen(handle, filename, flags.rawValue)
            }
        }

        return try ZipEntryFile(zipCheckResult(entryHandle))
    }

    // MARK: - Add/Remove Entries

    public struct AddFileFlags: OptionSet {
        public let rawValue: UInt32
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let overwrite = AddFileFlags(rawValue: ZIP_FL_OVERWRITE)
    }

    @discardableResult
    public func addDirectory(name: String) throws -> Int {
        return try name.withCString { name in
            return try zipCast(zipCheckResult(zip_dir_add(handle, name, ZIP_FL_ENC_UTF_8)))
        }
    }

    @discardableResult
    public func addFile(name: String, source: ZipSource, flags: AddFileFlags = []) throws -> Int {
        let result: Int = try name.withCString { name in
            return try zipCast(zipCheckResult(zip_file_add(handle, name, source.handle, flags.rawValue | ZIP_FL_ENC_UTF_8)))
        }

        // compensate unbalanced `free` inside `zip_file_add`
        source.keep()
        return result
    }

    public func deleteEntry(at index: Int) throws {
        try zipCheckResult(zip_delete(handle, zipCast(index)))
    }

    // MARK: - Revert Changes

    public func unchangeGlobals() throws {
        try zipCheckResult(zip_unchange_archive(handle))
    }

    public func unchangeAll() throws {
        try zipCheckResult(zip_unchange_all(handle))
    }
}
