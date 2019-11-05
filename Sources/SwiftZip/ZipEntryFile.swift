import zip

public final class ZipEntryFile: ZipErrorContext {
    internal var handle: OpaquePointer!

    internal init(_ handle: OpaquePointer) {
        self.handle = handle
    }

    deinit {
        if let handle = handle {
            let result = zip_fclose(handle)
            assert(result == ZIP_ER_OK)
        }
    }

    // MARK: - Error Context

    internal var error: ZipError? {
        return .zipError(zip_file_get_error(handle).pointee)
    }

    // MARK: - Open/Close

    public func close() {
        zip_fclose(handle)
        handle = nil
    }

    // MARK: - Entry I/O

    public func read(buf: UnsafeMutableRawPointer, count: Int) throws -> Int {
        return try zipCast(zipCheckResult(zip_fread(handle, buf, zipCast(count))))
    }

    public struct Whence: RawRepresentable {
        public let rawValue: Int32
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let SET = Whence(rawValue: SEEK_SET)
        public static let CUR = Whence(rawValue: SEEK_CUR)
        public static let END = Whence(rawValue: SEEK_END)
    }

    public func seek(offset: Int, whence: Whence) throws {
        try zipCheckResult(zip_fseek(handle, zipCast(offset), whence.rawValue))
    }

    public func tell() throws -> Int {
        return try zipCast(zipCheckResult(zip_ftell(handle)))
    }
}
