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

public struct ZipCompressionMethod: RawRepresentable, Equatable {
    public let rawValue: Int32
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
}

extension ZipCompressionMethod {
    /// default compression; currently the same as `deflate`, but flags are ignored.
    public static let `default` = ZipCompressionMethod(rawValue: ZIP_CM_DEFAULT)

    /// Store the file uncompressed.
    public static let store = ZipCompressionMethod(rawValue: ZIP_CM_STORE)

    /// Not supported by libzip/SwiftZip
    public static let shrink = ZipCompressionMethod(rawValue: ZIP_CM_SHRINK)

    /// Not supported by libzip/SwiftZip
    public static let reduce1 = ZipCompressionMethod(rawValue: ZIP_CM_REDUCE_1)

    /// Not supported by libzip/SwiftZip
    public static let reduce2 = ZipCompressionMethod(rawValue: ZIP_CM_REDUCE_2)

    /// Not supported by libzip/SwiftZip
    public static let reduce3 = ZipCompressionMethod(rawValue: ZIP_CM_REDUCE_3)

    /// Not supported by libzip/SwiftZip
    public static let reduce4 = ZipCompressionMethod(rawValue: ZIP_CM_REDUCE_4)

    /// Not supported by libzip/SwiftZip
    public static let implode = ZipCompressionMethod(rawValue: ZIP_CM_IMPLODE)

    /// Deflate the file with the zlib(3) algorithm and default options.
    public static let deflate = ZipCompressionMethod(rawValue: ZIP_CM_DEFLATE)

    /// Not supported by libzip/SwiftZip
    public static let deflate64 = ZipCompressionMethod(rawValue: ZIP_CM_DEFLATE64)

    /// Not supported by libzip/SwiftZip
    public static let pkwareImplode = ZipCompressionMethod(rawValue: ZIP_CM_PKWARE_IMPLODE)

    /// Compress the file using the bzip2(1) algorithm.
    public static let bzip2 = ZipCompressionMethod(rawValue: ZIP_CM_BZIP2)

    /// Not supported by libzip/SwiftZip
    public static let lzma = ZipCompressionMethod(rawValue: ZIP_CM_LZMA)

    /// Not supported by libzip/SwiftZip
    public static let terse = ZipCompressionMethod(rawValue: ZIP_CM_TERSE)

    /// Not supported by libzip/SwiftZip
    public static let lz77 = ZipCompressionMethod(rawValue: ZIP_CM_LZ77)

    /// Not supported by libzip/SwiftZip
    public static let lzma2 = ZipCompressionMethod(rawValue: ZIP_CM_LZMA2)

    /// Not supported by libzip/SwiftZip
    public static let xz = ZipCompressionMethod(rawValue: ZIP_CM_XZ)

    /// Not supported by libzip/SwiftZip
    public static let jpeg = ZipCompressionMethod(rawValue: ZIP_CM_JPEG)

    /// Not supported by libzip/SwiftZip
    public static let wavpack = ZipCompressionMethod(rawValue: ZIP_CM_WAVPACK)

    /// Not supported by libzip/SwiftZip
    public static let ppmd = ZipCompressionMethod(rawValue: ZIP_CM_PPMD)
}
