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

#if canImport(Darwin)

// Foundation-based encoding auto-detection available on Darwin only
// Linux Foundation does not support the required API

import Foundation
import SwiftZip

extension ZipArchive {
    /// Returns the comment for the entire zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_get_archive_comment](https://libzip.org/documentation/zip_get_archive_comment.html)
    ///
    /// - Parameters:
    ///   - version: archive version to use, defaults to `.current`
    public func getCommentGuessEncoding(version: Version = .current) throws -> String {
        if let decodedString = try getRawComment(version: version).decodeStringGuessingEncoding() {
            return decodedString
        } else {
            return try getComment(decodingStrategy: .guess, version: version)
        }
    }
}

extension ZipEntry {
    /// Returns the name of the file in the archive.
    ///
    /// - SeeAlso:
    ///   - [zip_get_name](https://libzip.org/documentation/zip_get_name.html)
    public final func getNameGuessEncoding() throws -> String {
        if let decodedString = try getRawName().decodeStringGuessingEncoding() {
            return decodedString
        } else {
            return try getName(decodingStrategy: .guess)
        }
    }
}

extension ZipEntry {
    /// Returns the comment for the file in the zip archive.
    ///
    /// - SeeAlso:
    ///   - [zip_file_get_comment](https://libzip.org/documentation/zip_file_get_comment.html)
    public final func getCommentGuessEncoding() throws -> String {
        if let decodedString = try getRawComment().decodeStringGuessingEncoding() {
            return decodedString
        } else {
            return try getComment(decodingStrategy: .guess)
        }
    }
}

extension Data {
    internal func decodeStringGuessingEncoding() -> String? {
        // Use Foundation string decoder on Darwin platforms
        var decodedString: NSString? = nil
        NSString.stringEncoding(for: self, encodingOptions: [.fromWindowsKey: true], convertedString: &decodedString, usedLossyConversion: nil)

        if let decodedString = decodedString {
            // Trim NULL terminators if any
            return decodedString.trimmingCharacters(in: ["\0"]) as String
        } else {
            return nil
        }
    }
}

#endif
