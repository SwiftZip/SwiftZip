import Foundation
import zip

public class ZipSource: ZipErrorContext {
    internal var handle: OpaquePointer!

    internal init(_ handle: OpaquePointer) {
        self.handle = handle
    }

    deinit {
        if let handle = handle {
            zip_source_free(handle)
        }
    }

    // MARK: - Error Context

    internal var error: ZipError? {
        return .zipError(zip_source_error(handle).pointee)
    }

    // MARK: - Create/Destroy

    public convenience init(buffer: UnsafeRawPointer, length: Int, freeWhenDone: Bool) throws {
        var error = zip_error_t()
        try self.init(zip_source_buffer_create(buffer, zipCast(length), freeWhenDone ? 1 : 0, &error).unwrapped(or: error))
    }

    public convenience init(filename: String, start: Int = 0, length: Int = -1) throws {
        let handle: OpaquePointer = try filename.withCString { filename in
            var error = zip_error_t()
            return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
        }

        self.init(handle)
    }

    public convenience init(url: URL, start: Int = 0, length: Int = -1) throws {
        let handle: OpaquePointer = try url.withUnsafeFileSystemRepresentation { filename in
            if let filename = filename {
                var error = zip_error_t()
                return try zip_source_file_create(filename, zipCast(start), zipCast(length), &error).unwrapped(or: error)
            } else {
                throw ZipError.unsupportedURL
            }
        }

        self.init(handle)
    }

    public convenience init(file: UnsafeMutablePointer<FILE>, start: Int = 0, length: Int = -1) throws {
        var error = zip_error_t()
        try self.init(zip_source_filep_create(file, zipCast(start), zipCast(length), &error).unwrapped(or: error))
    }

    public convenience init(callback: @escaping zip_source_callback, userdata: UnsafeMutableRawPointer? = nil) throws {
        var error = zip_error_t()
        try self.init(zip_source_function_create(callback, userdata, &error).unwrapped(or: error))
    }

    public func free() {
        zip_source_free(handle)
        handle = nil
    }
}
