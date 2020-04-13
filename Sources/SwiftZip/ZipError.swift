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

/// An error originating from SwiftZip or libzip.
public enum ZipError: Error {
    case libzipError(zip_error_t)
    case integerCastFailed
    case createFileFailed
    case unsupportedURL
    case archiveNotMutable
    case invalidArgument(String)
    case internalInconsistency
}

extension ZipError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case var .libzipError(error):
            return String(cString: zip_error_strerror(&error))
        case .integerCastFailed:
            return "Failed to cast integer value."
        case .createFileFailed:
            return "Failed to create file."
        case .unsupportedURL:
            return "SwiftZip supports file URLs only."
        case .archiveNotMutable:
            return "Failed to open the archive in read-write mode."
        case let .invalidArgument(name):
            return "Invalid value passed for argument `\(name)`."
        case .internalInconsistency:
            return "SwiftZip internal inconsistency."
        }
    }
}
