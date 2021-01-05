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

class ModificationTests: ZipTestCase {
    func testCanUpdateEntry() throws {
        let archiveUrl = tempFileURL(ext: "zip")
        try FileManager.default.copyItem(at: dataFileURL(for: "foreign-macos.zip"), to: archiveUrl)

        let updatedEntryName: String

        do {
            let archive = try ZipMutableArchive(url: archiveUrl)
            let firstEntry = try XCTUnwrap(archive.mutableEntries.first)
            updatedEntryName = try firstEntry.getName()
            try firstEntry.replace(with: ZipSource(data: .hello))
            try archive.close()
        }

        do {
            let archive = try ZipArchive(url: archiveUrl)
            let updatedEntry = try XCTUnwrap(archive.entries().first(where: { try $0.getName() == updatedEntryName }))
            try XCTAssertEqual(updatedEntry.data(), .hello)
        }
    }

    func testCanDeleteEntry() throws {
        let archiveUrl = tempFileURL(ext: "zip")
        try FileManager.default.copyItem(at: dataFileURL(for: "foreign-macos.zip"), to: archiveUrl)

        let removedEntryName: String

        do {
            let archive = try ZipMutableArchive(url: archiveUrl)
            let firstEntry = try XCTUnwrap(archive.mutableEntries.first)
            removedEntryName = try firstEntry.getName()
            try firstEntry.delete()
            try archive.close()
        }

        do {
            let archive = try ZipArchive(url: archiveUrl)
            let entry = try archive.entries().first(where: { try $0.getName() == removedEntryName })
            XCTAssertNil(entry)
        }
    }

    func testCanReameEntry() throws {
        let archiveUrl = tempFileURL(ext: "zip")
        try FileManager.default.copyItem(at: dataFileURL(for: "foreign-macos.zip"), to: archiveUrl)

        let newEntryName = "123.ppp"

        do {
            let archive = try ZipMutableArchive(url: archiveUrl)
            let firstEntry = try XCTUnwrap(archive.mutableEntries.first)
            try firstEntry.rename(to: newEntryName)
            try archive.close()
        }

        do {
            let archive = try ZipArchive(url: archiveUrl)
            let entry = try archive.entries().first(where: { try $0.getName() == newEntryName })
            XCTAssertNotNil(entry)
        }
    }
}
