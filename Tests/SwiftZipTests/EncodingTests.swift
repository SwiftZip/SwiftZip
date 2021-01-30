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

// Test encoding auto-detection on Darwin only
// Linux Foundation does not support the required API

import Foundation
import SwiftZip
import SwiftZipUtils
import XCTest

class EncodingTests: ZipTestCase {
    private struct TestCase {
        let archive: String
        let entries: Set<String>
        let file: StaticString
        let line: UInt

        init(archive: String, entries: Set<String>, file: StaticString = #filePath, line: UInt = #line) {
            self.archive = archive
            self.entries = entries
            self.file = file
            self.line = line
        }
    }

    private static let testCases: [TestCase] = [
        TestCase(
            archive: "foreign-dos.zip",
            entries: [
                "programmer.png",
                "繁體中文/時間/",
                "繁體中文/文本檔案.txt",
                "简体中文/新建文本文档.txt"
            ]
        ),
        TestCase(
            archive: "foreign-windows.zip",
            entries: [
                "programmer.png",
                "вｙe вｙЁəiεə.txt",
                "ㅂㄶㄵㅁㅀもぬに.txt",
                "简体中文/",
                "简体中文/新建文本文档.txt",
                "繁體中文/",
                "繁體中文/文本檔案.txt",
                "繁體中文/時間/"
            ]
        ),
        TestCase(
            archive: "foreign-macos.zip",
            entries: [
                "test.png",
                "macOS/",
                "macOS/print.sh",
                "macOS/卍〆◈(*`ェ´*)/",
                "English🔣🅿️⌘/",
                "繁體简体 abc 123▦░▥▨▩┏◈〆卍/"
            ]
        ),
    ]

    func testEntryNameEncodingDetection() throws {
        for testCase in Self.testCases {
            let archive = try ZipArchive(url: dataFileURL(for: testCase.archive))
            let entries = try archive.entries().map { try $0.getNameGuessEncoding() }
            XCTAssertEqual(Set(entries), testCase.entries, file: testCase.file, line: testCase.line)
        }
    }
}

#endif
