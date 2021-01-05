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
import TestData
import XCTest

class EndToEndTests: ZipTestCase {
    func testCanHandleSmallData() throws {
        let archiveUrl = tempFileURL(ext: "zip")

        do {
            let zip = try ZipMutableArchive(url: archiveUrl, flags: [.create, .truncate])
            try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
            try zip.close()
        }

        do {
            let zip = try ZipArchive(url: archiveUrl)
            let entry = try zip.locate(filename: Constants.entryName)
            try XCTAssertEqual(entry.data(), .hello)
        }
    }

    func testCanHandleLargeData() throws {
        let archiveUrl = tempFileURL(ext: "zip")

        do {
            let zip = try ZipMutableArchive(url: archiveUrl, flags: [.create, .truncate])
            try zip.addFile(name: Constants.entryName, source: ZipSource(data: .large))
            try zip.close()
        }

        do {
            let zip = try ZipArchive(url: archiveUrl)
            let entry = try zip.locate(filename: Constants.entryName)
            try XCTAssertEqual(entry.data(), .large)
        }
    }

    func testCanHandleSmallDataAes256() throws {
        let archiveUrl = tempFileURL(ext: "zip")

        do {
            let zip = try ZipMutableArchive(url: archiveUrl, flags: [.create, .truncate])
            let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
            try entry.setEncryption(method: .aes256, password: Constants.password)
            try zip.close()
        }

        do {
            let zip = try ZipArchive(url: archiveUrl)
            let entry = try zip.locate(filename: Constants.entryName)
            try XCTAssertEqual(entry.data(password: Constants.password), .hello)
        }
    }

    func testCanHandleLargeDataAes128() throws {
        let archiveUrl = tempFileURL(ext: "zip")

        do {
            let zip = try ZipMutableArchive(url: archiveUrl, flags: [.create, .truncate])
            let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .large))
            try entry.setEncryption(method: .aes128, password: Constants.password)
            try zip.close()
        }

        do {
            let zip = try ZipArchive(url: archiveUrl)
            let entry = try zip.locate(filename: Constants.entryName)
            try XCTAssertEqual(entry.data(password: Constants.password), .large)
        }
    }
}
