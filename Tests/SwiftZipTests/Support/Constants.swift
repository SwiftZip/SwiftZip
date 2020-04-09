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

enum Constants {
    static let archiveComment = "test archive comment"

    static let entryName = "test.txt"

    static let entryComment = "test entry comment"

    static let firstExtraField: UInt16 = 0xAA

    static let firstExtraFieldDataLocal = "first extra field local"
        .data(using: .utf8)!

    static let firstExtraFieldDataCentral = "first extra field central"
        .data(using: .utf8)!

    static let secondExtraField: UInt16 = 0xBB

    static let secondExtraFieldData = "second extra field"
        .data(using: .utf8)!

    static let helloData = "Hello, World!"
        .data(using: .utf8)!

    static let largeData = stride(from: 0, to: 17 * 17 * 17 * 17, by: 1)
        .map { "Hello, World #\($0)!" }
        .joined(separator: " ")
        .data(using: .utf8)!
}
