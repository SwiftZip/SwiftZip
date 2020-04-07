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

public struct ZipStringDecodingStrategy: RawRepresentable, Equatable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Guess the encoding of the string in the ZIP archive and convert it to UTF-8, if necessary.
    public static let guess = ZipStringDecodingStrategy(rawValue: ZIP_FL_ENC_GUESS)

    /// Follow the ZIP specification for file names and extend it to file comments, expecting them
    /// to be encoded in CP-437 in the ZIP archive (except if it is a UTF-8 comment from the
    /// special extra field). Convert it to UTF-8.
    public static let strict = ZipStringDecodingStrategy(rawValue: ZIP_FL_ENC_STRICT)
}
