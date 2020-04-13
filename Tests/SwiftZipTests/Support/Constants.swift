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
import SwiftZip

enum TestArchive: String {
    case archiveComment = "archive-comment.zip"
    case entryComment = "entry-comment.zip"
    case modifiedDate = "modified-date.zip"
    case externalAttributes = "external-attributes.zip"
    case extraSingleLocal = "extra-single-local.zip"
    case extraSingleCentral = "extra-single-central.zip"
    case extraSingleBoth = "extra-single-both.zip"
    case extraDoubleLocal = "extra-double-local.zip"
    case extraDoubleCentral = "extra-double-central.zip"
    case extraDoubleBoth = "extra-double-both.zip"
    case extraTwoLocal = "extra-two-local.zip"
    case extraTwoCentral = "extra-two-central.zip"
    case simpleSmall = "simple-small.zip"
    case simpleLarge = "simple-large.zip"
    case encryptedSmall = "encrypted-small.zip"
    case encryptedLarge = "encrypted-large.zip"
}

enum Constants {
    static let entryName = "test.txt"
    static let password = "test password"
    static let modifiedDate = Date(timeIntervalSinceReferenceDate: 42)
    static let externalSystem = ZipEntry.ExternalAttributes.OperatingSystem.beOS
    static let externalAttributes: UInt32 = 0xABBABABA
    static let archiveComment = "test archive comment"
    static let entryComment = "test entry comment"
    static let firstExtraField: UInt16 = 0xAA
    static let secondExtraField: UInt16 = 0xBB
}

extension Data {
    static let firstExtraFieldLocal = "first extra field local"
        .data(using: .utf8)!

    static let firstExtraFieldLocal2 = "first extra field local #2"
        .data(using: .utf8)!

    static let firstExtraFieldCentral = "first extra field central"
        .data(using: .utf8)!

    static let firstExtraFieldCentral2 = "first extra field central #2"
        .data(using: .utf8)!

    static let secondExtraField = "second extra field"
        .data(using: .utf8)!

    static let hello = "Hello, World!"
        .data(using: .utf8)!

    static let large = stride(from: 0, to: 17 * 17 * 17 * 17, by: 1)
        .map { "Hello, World #\($0)!" }
        .joined(separator: " ")
        .data(using: .utf8)!
}
