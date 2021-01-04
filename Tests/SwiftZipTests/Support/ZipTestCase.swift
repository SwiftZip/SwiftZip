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
import TestData
import XCTest

class ZipTestCase: XCTestCase {
    private static let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

    private static let dataDirectory = URL(fileURLWithPath: #file)
        .deletingLastPathComponent() // Root/Tests/SwiftZipTests/Support/
        .deletingLastPathComponent() // Root/Tests/SwiftZipTests/
        .appendingPathComponent("Data", isDirectory: true)

    private let tempDirectory = tempRoot
        .appendingPathComponent(UUID().uuidString, isDirectory: true)

    override func setUpWithError() throws {
        super.setUp()
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func tempFileURL(ext: String) -> URL {
        return tempDirectory.appendingPathComponent(UUID().uuidString, isDirectory: false).appendingPathExtension(ext)
    }

    func dataFileURL(for archive: TestArchive) -> URL {
        return Self.dataDirectory.appendingPathComponent(archive.rawValue, isDirectory: false)
    }
}
