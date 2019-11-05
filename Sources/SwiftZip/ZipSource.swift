import Foundation
import zip

open class ZipSource: ZipErrorContext {
    internal let handle: OpaquePointer

    // MARK: - Error Context

    internal var error: ZipError? {
        return .zipError(zip_source_error(handle).pointee)
    }

    // MARK: - Create/Destroy

    public init(buffer: UnsafeRawPointer, length: Int, freeWhenDone: Bool) throws {
        var error = zip_error_t()
        self.handle = try zip_source_buffer_create(buffer, zipCast(length), freeWhenDone ? 1 : 0, &error).unwrapped(or: error)
    }

    public init(filename: String, start: Int = 0, length: Int = -1) throws {
        self.handle = try filename.withCString { filename in
            var error = zip_error_t()
            return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
        }
    }

    public init(url: URL, start: Int = 0, length: Int = -1) throws {
        self.handle = try url.withUnsafeFileSystemRepresentation { filename in
            if let filename = filename {
                var error = zip_error_t()
                return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
            } else {
                throw ZipError.unsupportedURL
            }
        }
    }

    public init(file: UnsafeMutablePointer<FILE>, start: Int = 0, length: Int = -1) throws {
        var error = zip_error_t()
        self.handle = try zip_source_filep_create(file, zipCast(start), zipCast(length), &error).unwrapped(or: error)
    }

    public init(callback: @escaping zip_source_callback, userdata: UnsafeMutableRawPointer? = nil) throws {
        var error = zip_error_t()
        self.handle = try zip_source_function_create(callback, userdata, &error).unwrapped(or: error)
    }

    internal func keep() {
        zip_source_keep(handle)
    }

    deinit {
        zip_source_free(handle)
    }
}
