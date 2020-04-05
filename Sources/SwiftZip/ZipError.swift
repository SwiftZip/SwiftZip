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

// MARK: - ZipError

public enum ZipError: Error {
    case zipError(zip_error_t)
    case integerCastFailed
    case unsupportedURL
    case internalInconsistency
}

extension ZipError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case var .zipError(error):
            return String(cString: zip_error_strerror(&error))
        case .integerCastFailed:
            return "Failed to cast integer value."
        case .unsupportedURL:
            return "SwiftZip supports file URLs only."
        case .internalInconsistency:
            return "SwiftZip internal inconsistency."
        }
    }
}

// MARK: - Error Code Handling

internal func zipCheckError(_ errorCode: Int32) throws {
    switch errorCode {
    case ZIP_ER_OK:
        return
    case let errorCode:
        throw ZipError.zipError(.init(zip_err: errorCode, sys_err: 0, str: nil))
    }
}

// MARK: - Int Cast

internal func zipCast<T, U>(_ value: T) throws -> U where T: BinaryInteger, U: BinaryInteger {
    if let result = U(exactly: value) {
        return result
    } else {
        throw ZipError.integerCastFailed
    }
}

// MARK: - Optional Unwrapping

extension Optional {
    internal func unwrapped() throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            assertionFailure()
            throw ZipError.internalInconsistency
        }
    }

    internal func unwrapped(or error: zip_error) throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            throw ZipError.zipError(error)
        }
    }
}

// MARK: - Error Context

internal protocol ZipErrorContext {
    var error: ZipError? { get }
}

extension ZipErrorContext {
    @discardableResult
    internal func zipCheckResult<T>(_ returnCode: T) throws -> T where T: BinaryInteger {
        if returnCode == -1 {
            throw try error.unwrapped()
        } else {
            return returnCode
        }
    }

    internal func zipCheckResult<T>(_ value: T?) throws -> T {
        switch value {
        case let .some(value):
            return value
        case .none:
            throw try error.unwrapped()
        }
    }
}
