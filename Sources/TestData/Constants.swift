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

public enum TestArchive: String {
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
    case largeForExport = "large-for-export.zip"
}

public enum Constants {
    public static let entryName = "test.txt"
    public static let password = "test password"
    public static let modifiedDate = Date(timeIntervalSinceReferenceDate: 42)
    public static let externalSystem = ZipEntry.ExternalAttributes.OperatingSystem.beOS
    public static let externalAttributes: UInt32 = 0xABBABABA
    public static let archiveComment = "test archive comment"
    public static let entryComment = "test entry comment"
    public static let firstExtraField: UInt16 = 0xAA
    public static let secondExtraField: UInt16 = 0xBB
    public static let posixPermissions: mode_t = 0o765
}

extension Data {
    public static let firstExtraFieldLocal = "first extra field local"
        .data(using: .utf8)!

    public static let firstExtraFieldLocal2 = "first extra field local #2"
        .data(using: .utf8)!

    public static let firstExtraFieldCentral = "first extra field central"
        .data(using: .utf8)!

    public static let firstExtraFieldCentral2 = "first extra field central #2"
        .data(using: .utf8)!

    public static let secondExtraField = "second extra field"
        .data(using: .utf8)!

    public static let hello = "Hello, World!"
        .data(using: .utf8)!

    public static let large = stride(from: 0, to: 17 * 17 * 17 * 17, by: 1)
        .map { "Hello, World #\($0)!" }
        .joined(separator: " ")
        .data(using: .utf8)!
}
