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

extension ZipEntry {
    /// Properties of the archive etry.
    public struct Stat {
        internal var stat: zip_stat = zip_stat()
    }
}

extension ZipEntry.Stat {
    /// Which fields have valid values
    public var validFields: ValidFields {
        return ValidFields(rawValue: stat.valid)
    }

    /// Name of the file
    public var rawName: Data? {
        if validFields.contains(.name) {
            return stat.name.flatMap(Data.init(cString:))
        } else {
            return nil
        }
    }

    /// Index within archive
    public var index: UInt64? {
        if validFields.contains(.index) {
            return stat.index
        } else {
            return nil
        }
    }

    /// Size of file (uncompressed)
    public var size: Int? {
        if validFields.contains(.size) {
            return zipNoThrow {
                try zipCast(stat.size)
            }
        } else {
            return nil
        }
    }

    /// Size of file (compressed)
    public var compressedSize: Int? {
        if validFields.contains(.compressedSize) {
            return zipNoThrow {
                try zipCast(stat.comp_size)
            }
        } else {
            return nil
        }
    }

    /// Modification date and time
    public var modificationDate: Date? {
        if validFields.contains(.modificationDate) {
            return Date(timeIntervalSince1970: TimeInterval(stat.mtime))
        } else {
            return nil
        }
    }

    /// CRC32 of file data
    public var crc32: UInt32? {
        if validFields.contains(.crc32) {
            return stat.crc
        } else {
            return nil
        }
    }

    /// Compression method used
    public var compressionMethod: ZipEntry.CompressionMethod? {
        if validFields.contains(.compressionMethod) {
            return .init(rawValue: Int32(stat.comp_method))
        } else {
            return nil
        }
    }

    /// Encryption method used
    public var encryptionMethod: ZipEntry.EncryptionMethod? {
        if validFields.contains(.encryptionMethod) {
            return .init(rawValue: stat.encryption_method)
        } else {
            return nil
        }
    }

    /// Reserved for future use
    public var flags: UInt32? {
        if validFields.contains(.flags) {
            return stat.flags
        } else {
            return nil
        }
    }
}
