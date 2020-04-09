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

/// An encryption method.
public struct ZipEncryptionMethod: RawRepresentable, Equatable {
    public let rawValue: UInt16
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension ZipEncryptionMethod {
    /// Not encrypted.
    public static let none = ZipEncryptionMethod(rawValue: UInt16(ZIP_EM_NONE))

    /// Traditional PKWARE encryption.
    public static let pkware = ZipEncryptionMethod(rawValue: UInt16(ZIP_EM_TRAD_PKWARE))

    /// Winzip AES-128 encryption.
    public static let aes128 = ZipEncryptionMethod(rawValue: UInt16(ZIP_EM_AES_128))

    /// Winzip AES-192 encryption.
    public static let aes192 = ZipEncryptionMethod(rawValue: UInt16(ZIP_EM_AES_192))

    /// Winzip AES-256 encryption.
    public static let aes256 = ZipEncryptionMethod(rawValue: UInt16(ZIP_EM_AES_256))
}
