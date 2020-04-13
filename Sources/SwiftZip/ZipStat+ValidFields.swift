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

extension ZipStat {
    /// A set of valid property values in the `ZipEntry.Stat` struct.
    public struct ValidFields: OptionSet {
        public let rawValue: UInt64

        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
    }
}

extension ZipStat.ValidFields {
    public static let name = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_NAME))
    public static let index = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_INDEX))
    public static let size = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_SIZE))
    public static let compressedSize = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_COMP_SIZE))
    public static let modificationDate = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_MTIME))
    public static let crc32 = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_CRC))
    public static let compressionMethod = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_COMP_METHOD))
    public static let encryptionMethod = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_ENCRYPTION_METHOD))
    public static let flags = ZipStat.ValidFields(rawValue: UInt64(ZIP_STAT_FLAGS))
}
