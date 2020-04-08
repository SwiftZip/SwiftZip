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

// MARK: - Throwing numeric cast

internal func zipCast<T, U>(_ value: T, function: StaticString = #function, file: StaticString = #file, line: Int = #line) throws -> U where T: BinaryInteger, U: BinaryInteger {
    if let result = U(exactly: value) {
        return result
    } else {
        assertionFailure("Numeric cast failed in `\(function)` at `\(file):\(line)`")
        throw ZipError.integerCastFailed
    }
}

// MARK: - Throwing downcast

internal func zipCast<T, U>(_ value: T, as _: U.Type, function: StaticString = #function, file: StaticString = #file, line: Int = #line) throws -> U {
    if let result = value as? U {
        return result
    } else {
        assertionFailure("Dynamic cast failed in `\(function)` at `\(file):\(line)`")
        throw ZipError.internalInconsistency
    }
}

// MARK: - Create `Data` from NULL-terminated string

extension Data {
    internal init(cString bytes: UnsafePointer<Int8>) {
        self.init(bytes: bytes, count: strlen(bytes) + 1)
    }
}

// MARK: - Linux shim for `autoreleasepool`

#if !canImport(ObjectiveC)

@_transparent
internal func autoreleasepool<T>(_ block: () throws -> T) rethrows -> T {
    return try block()
}

#endif
