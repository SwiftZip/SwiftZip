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
import XCTest
import SwiftZip

class BaseTestCase: XCTestCase {
    private static let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    private static let tempDirectory = tempRoot.appendingPathComponent(UUID().uuidString, isDirectory: true)

    override class func setUp() {
        super.setUp()
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    override class func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func tempFile(type ext: String) -> URL {
        return Self.tempDirectory.appendingPathComponent(UUID().uuidString, isDirectory: false).appendingPathExtension(ext)
    }
}

class SampleTest: BaseTestCase {
    func testExample() throws {
        let archive = try ZipArchive(url: tempFile(type: "zip"), flags: [.create, .truncate])
        let source = try ZipSourceData(data: "Hello".data(using: .utf8)!)
        try archive.addFile(name: "test.txt", source: source)
        try archive.close()
    }

    func testExample2() throws {
        let archiveUrl = tempFile(type: "zip")
        let largeString = Array(repeating: String("Hello, world!"), count: 1000).joined()

        do {
            let archive = try ZipArchive(url: archiveUrl, flags: [.create, .truncate])
            let source1 = try ZipSourceData(data: "Hello".data(using: .utf8)!)
            try archive.addFile(name: "test.txt", source: source1)
            let source2 = try ZipSourceData(data: largeString.data(using: .utf8)!)
            try archive.addFile(name: "large.txt", source: source2)
            try archive.close()
        }

        do {
            let archive = try ZipArchive(url: archiveUrl, flags: [.readOnly])
            let entry = try archive.locate(filename: "test.txt")
            try XCTAssertEqual(String(data: entry.data(), encoding: .utf8)!, "Hello")
            try archive.close()
        }

        do {
            let fileUrl = tempFile(type: "txt")
            let archive = try ZipArchive(url: archiveUrl, flags: [.readOnly])
            let entry = try archive.locate(filename: "large.txt")
            try entry.save(to: fileUrl)
            try XCTAssertEqual(String(contentsOf: fileUrl, encoding: .utf8), largeString)
            try archive.close()
        }
    }
}
