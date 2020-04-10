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

internal protocol ZipErrorContext {
    var lastError: zip_error_t? { get }
    func clearError()
}

extension ZipErrorContext {
    @discardableResult
    internal func zipCheckResult<T>(_ returnCode: T) throws -> T where T: SignedInteger {
        if returnCode == -1 {
            defer { clearError() }
            throw try ZipError.zipError(lastError.unwrapped())
        } else {
            return returnCode
        }
    }

    internal func zipCheckResult<T>(_ value: T?) throws -> T {
        switch value {
        case let .some(value):
            return value
        case .none:
            defer { clearError() }
            throw try ZipError.zipError(lastError.unwrapped())
        }
    }
}
