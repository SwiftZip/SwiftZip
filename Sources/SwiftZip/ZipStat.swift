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

/// Properties of the archive etry.
public struct ZipStat {
    internal var rawValue: zip_stat

    internal init(uninitialized: Void) {
        self.rawValue = zip_stat()
    }
}

extension ZipStat {
    public init(size: Int? = nil, compressedSize: Int? = nil, modificationDate: Date? = nil, crc32: UInt32? = nil, compressionMethod: CompressionMethod? = nil, encryptionMethod: EncryptionMethod? = nil, flags: UInt32? = nil) {
        self.init(uninitialized: ())
        zip_stat_init(&rawValue)

        self.size = size
        self.compressedSize = compressedSize
        self.modificationDate = modificationDate
        self.crc32 = crc32
        self.compressionMethod = compressionMethod
        self.encryptionMethod = encryptionMethod
        self.flags = flags
    }
}

extension ZipStat {
    /// Set of valid fields in a struct
    public private(set) var validFields: ValidFields {
        get {
            return ValidFields(rawValue: rawValue.valid)
        }
        set {
            rawValue.valid = newValue.rawValue
        }
    }

    /// Name of the file
    public var rawName: Data? {
        if validFields.contains(.name) {
            return rawValue.name.flatMap(Data.init(cString:))
        } else {
            return nil
        }
    }

    /// Index within archive
    public var index: UInt64? {
        if validFields.contains(.index) {
            return rawValue.index
        } else {
            return nil
        }
    }
}

extension ZipStat {
    /// Size of file (uncompressed)
    public var size: Int? {
        get {
            if validFields.contains(.size) {
                return assertNoThrow(or: nil) {
                    try integerCast(rawValue.size)
                }
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                assertNoThrow(or: nil) {
                    rawValue.size = try integerCast(newValue)
                    validFields.insert(.size)
                }
            } else {
                validFields.remove(.size)
            }
        }
    }

    /// Size of file (compressed)
    public var compressedSize: Int? {
        get {
            if validFields.contains(.compressedSize) {
                return assertNoThrow(or: nil) {
                    try integerCast(rawValue.comp_size)
                }
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                assertNoThrow(or: nil) {
                    rawValue.comp_size = try integerCast(newValue)
                    validFields.insert(.compressedSize)
                }
            } else {
                validFields.remove(.compressedSize)
            }
        }
    }

    /// Modification date and time
    public var modificationDate: Date? {
        get {
            if validFields.contains(.modificationDate) {
                return Date(timeIntervalSince1970: TimeInterval(rawValue.mtime))
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                assertNoThrow {
                    rawValue.mtime = try integerCast(Int(newValue.timeIntervalSince1970))
                    validFields.insert(.modificationDate)
                }
            } else {
                validFields.remove(.modificationDate)
            }
        }
    }

    /// CRC32 of file data
    public var crc32: UInt32? {
        get {
            if validFields.contains(.crc32) {
                return rawValue.crc
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                rawValue.crc = newValue
                validFields.insert(.crc32)
            } else {
                validFields.remove(.crc32)
            }
        }
    }

    /// Compression method used
    public var compressionMethod: CompressionMethod? {
        get {
            if validFields.contains(.compressionMethod) {
                return .init(rawValue: Int32(rawValue.comp_method))
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                assertNoThrow {
                    rawValue.comp_method = try integerCast(newValue.rawValue)
                    validFields.insert(.compressionMethod)
                }
            } else {
                validFields.remove(.compressionMethod)
            }
        }
    }

    /// Encryption method used
    public var encryptionMethod: EncryptionMethod? {
        get {
            if validFields.contains(.encryptionMethod) {
                return .init(rawValue: rawValue.encryption_method)
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                rawValue.encryption_method = newValue.rawValue
                validFields.insert(.encryptionMethod)
            } else {
                validFields.remove(.encryptionMethod)
            }
        }
    }

    /// Reserved for future use
    public var flags: UInt32? {
        get {
            if validFields.contains(.flags) {
                return rawValue.flags
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                rawValue.flags = newValue
                validFields.insert(.flags)
            } else {
                validFields.remove(.flags)
            }
        }
    }
}
