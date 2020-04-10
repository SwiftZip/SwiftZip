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

import zip

internal func zipSourceCallbackProxy(userdata: UnsafeMutableRawPointer?, data: UnsafeMutableRawPointer?, length: zip_uint64_t, command: zip_source_cmd_t) -> zip_int64_t {
    guard let userdata = userdata else {
        preconditionFailure("")
    }

    let proxy = Unmanaged<ZipSourceCallbackProxy>.fromOpaque(userdata)
    let result = proxy.takeUnretainedValue().callback(data: data, length: length, command: command)

    if command == ZIP_SOURCE_FREE {
        proxy.release()
    }

    return result
}

internal final class ZipSourceCallbackProxy {
    private let callback: ZipSourceCallback
    private var error: Error?

    internal init(callback: ZipSourceCallback) {
        self.callback = callback
    }
}

extension ZipSourceCallbackProxy {
    fileprivate func callback(data: UnsafeMutableRawPointer?, length: zip_uint64_t, command: zip_source_cmd_t) -> zip_int64_t {
        do {
            switch command {
            case ZIP_SOURCE_ACCEPT_EMPTY:
                // Return 1 if an empty source should be accepted as a valid zip archive. This is the default
                // if this command is not supported by a source. File system backed sources should return 0.

                preconditionFailure("Got unsupported source command: `ZIP_SOURCE_ACCEPT_EMPTY`")

            case ZIP_SOURCE_SUPPORTS:
                // Return bitmap specifying which commands are supported. Use zip_source_make_command_bitmap(3). If this command
                // is not implemented, the source is assumed to be a read source without seek support.

                var result = 0
                    | ZIP_SOURCE_SUPPORTS.bitmap
                    | ZIP_SOURCE_FREE.bitmap

                if callback is ZipSourceReadable {
                    result = result
                        | ZIP_SOURCE_OPEN.bitmap
                        | ZIP_SOURCE_READ.bitmap
                        | ZIP_SOURCE_CLOSE.bitmap
                        | ZIP_SOURCE_STAT.bitmap
                        | ZIP_SOURCE_ERROR.bitmap
                }

                if callback is ZipSourceSeekable {
                    result = result
                        | ZIP_SOURCE_SEEK.bitmap
                        | ZIP_SOURCE_TELL.bitmap
                }

                if callback is ZipSourceWritable {
                    result = result
                        | ZIP_SOURCE_BEGIN_WRITE.bitmap
                        | ZIP_SOURCE_WRITE.bitmap
                        | ZIP_SOURCE_COMMIT_WRITE.bitmap
                        | ZIP_SOURCE_ROLLBACK_WRITE.bitmap
                        | ZIP_SOURCE_SEEK_WRITE.bitmap
                        | ZIP_SOURCE_TELL_WRITE.bitmap
                        | ZIP_SOURCE_REMOVE.bitmap
                }

                return result

            case ZIP_SOURCE_FREE:
                // Clean up and free all resources, including userdata. The callback function will not be called again.

                return 0

            // MARK: ZipSourceRaadable

            case ZIP_SOURCE_OPEN:
                // Prepare for reading.

                let source = try zipCast(self.callback, as: ZipSourceReadable.self)
                try source.open()
                return 0

            case ZIP_SOURCE_READ:
                // Read data into the buffer data of size len. Return the number of bytes placed into data on success, and
                // zero for end-of-file.

                let source = try zipCast(self.callback, as: ZipSourceReadable.self)
                return try zipCast(source.read(to: data.unwrapped(), count: zipCast(length)))

            case ZIP_SOURCE_CLOSE:
                // Reading is done.

                let source = try zipCast(self.callback, as: ZipSourceReadable.self)
                try source.close()
                return 0

            case ZIP_SOURCE_STAT:
                // Get meta information for the input data. data points to an allocated struct zip_stat, which should
                // be initialized using zip_stat_init(3) and then filled in.
                // For uncompressed, unencrypted data, all information is optional. However, fill in as much information
                // as is readily available.
                // If the data is compressed, ZIP_STAT_COMP_METHOD, ZIP_STAT_SIZE, and ZIP_STAT_CRC must be filled in.
                // If the data is encrypted, ZIP_STAT_ENCRYPTION_METHOD, ZIP_STAT_COMP_METHOD, ZIP_STAT_SIZE,
                // and ZIP_STAT_CRC must be filled in.
                // Information only available after the source has been read (e.g., size) can be omitted in an earlier call.
                // NOTE: zip_source_function() may be called with this argument even after being called with ZIP_SOURCE_CLOSE.
                // Return sizeof(struct zip_stat) on success.

                let source = try zipCast(self.callback, as: ZipSourceReadable.self)
                let stat = try source.stat()
                let data = try data.unwrapped().assumingMemoryBound(to: zip_stat.self)
                zip_stat_init(data)

                if let value = stat.size { data.pointee.size = try zipCast(value) }
                if let value = stat.compressedSize { data.pointee.comp_size = try zipCast(value) }
                if let value = stat.modificationDate { data.pointee.mtime = try zipCast(Int(value.timeIntervalSince1970)) }
                if let value = stat.crc32 { data.pointee.crc = value }
                if let value = stat.compressionMethod { data.pointee.comp_method = try zipCast(value.rawValue) }
                if let value = stat.encryptionMethod { data.pointee.encryption_method = value.rawValue }
                if let value = stat.flags { data.pointee.flags = value }
                return try zipCast(MemoryLayout<zip_stat>.size)

            case ZIP_SOURCE_ERROR:
                // Get error information. data points to an array of two ints, which should be filled with the libzip error
                // code and the corresponding system error code for the error that occurred. See zip_errors(3) for details
                // on the error codes. If the source stores error information in a zip_error_t, use zip_error_to_data(3)
                // and return its return value. Otherwise, return 2 * sizeof(int).

                // TODO: expose error to libzip
                return try zipCast(2 * MemoryLayout<Int>.size)

            // MARK: ZipSourceSeekable

            case ZIP_SOURCE_SEEK:
                // Specify position to read next byte from, like fseek(3). Use ZIP_SOURCE_GET_ARGS(3) to decode
                // the arguments into the following struct:
                // struct zip_source_args_seek {
                //     zip_int64_t offset;
                //     int whence;
                // };
                // If the size of the source's data is known, use zip_source_seek_compute_offset(3) to validate
                // the arguments and compute the new offset.

                let source = try zipCast(self.callback, as: ZipSourceSeekable.self)
                let data = try data.unwrapped().assumingMemoryBound(to: zip_source_args_seek_t.self)
                try source.seek(offset: zipCast(data.pointee.offset), whence: ZipWhence(rawValue: data.pointee.whence))
                return 0

            case ZIP_SOURCE_TELL:
                // Return the current read offset in the source, like ftell(3).

                let source = try zipCast(self.callback, as: ZipSourceSeekable.self)
                return try zipCast(source.tell())

            // MARK: ZipSourceWritable

            case ZIP_SOURCE_BEGIN_WRITE:
                // Prepare the source for writing. Use this to create any temporary file(s).

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                try source.beginWrite()
                return 0

            case ZIP_SOURCE_BEGIN_WRITE_CLONING:
                // Prepare the source for writing, keeping the first len bytes of the original file. Only implement
                // this command if it is more efficient than copying the data, and if it does not destructively overwrite
                // the original file (you still have to be able to execute ZIP_SOURCE_ROLLBACK_WRITE).
                // The next write should happen at byte offset.

                preconditionFailure("Got unsupported source command: `ZIP_SOURCE_BEGIN_WRITE_CLONING`")

            case ZIP_SOURCE_WRITE:
                // Write data to the source. Return number of bytes written.

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                return try zipCast(source.write(bytes: data.unwrapped(), count: zipCast(length)))

            case ZIP_SOURCE_COMMIT_WRITE:
                // Finish writing to the source. Replace the original data with the newly written data. Clean up temporary
                // files or internal buffers. Subsequently opening and reading from the source should return the newly written data.

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                try source.commitWrite()
                return 0

            case ZIP_SOURCE_ROLLBACK_WRITE:
                // Abort writing to the source. Discard written data. Clean up temporary files or internal buffers.
                // Subsequently opening and reading from the source should return the original data.

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                try source.rollbackWrite()
                return 0

            case ZIP_SOURCE_SEEK_WRITE:
                // Specify position to write next byte to, like fseek(3). See ZIP_SOURCE_SEEK for details.

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                let data = try data.unwrapped().assumingMemoryBound(to: zip_source_args_seek_t.self)
                try source.seekWrite(offset: zipCast(data.pointee.offset), whence: ZipWhence(rawValue: data.pointee.whence))
                return 0

            case ZIP_SOURCE_TELL_WRITE:
                // Return the current write offset in the source, like ftell(3).

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                return try zipCast(source.tellWrite())

            case ZIP_SOURCE_REMOVE:
                // Remove the underlying file. This is called if a zip archive is empty when closed.

                let source = try zipCast(self.callback, as: ZipSourceWritable.self)
                try source.remove()
                return 0

            default:
                preconditionFailure("Got unsupported source command: \(command)")
            }
        } catch {
            self.error = error
            return -1
        }
    }
}

private extension zip_source_cmd_t {
    var bitmap: zip_int64_t {
        return 1 << rawValue
    }
}
