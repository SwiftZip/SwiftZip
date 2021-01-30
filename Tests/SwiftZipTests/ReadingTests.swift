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
import XCTest

class ReadingTests: ZipTestCase {
    func testCanReadSmallEntry() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .simpleSmall))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.data(), .hello)
    }

    func testCanReadLargeEntry() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .simpleLarge))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.data(), .large)
    }

    func testCanReadModifiedDate() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .modifiedDate))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(
            entry.stat().modificationDate!.timeIntervalSinceReferenceDate,
            Constants.modifiedDate.addingTimeInterval(-TimeInterval(NSTimeZone.system.secondsFromGMT())).timeIntervalSinceReferenceDate,
            accuracy: 0.001)
    }

    func testCanReadExternalAttributes() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .externalAttributes))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExternalAttributes().operatingSystem, Constants.externalSystem)
        try XCTAssertEqual(entry.getExternalAttributes().attributes, Constants.externalAttributes)
    }

    func testCanReadSmallEntryAes192() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .encryptedSmall))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.stat().encryptionMethod, .aes192)
        try XCTAssertEqual(entry.data(password: Constants.password), .hello)
    }

    func testCanReadLargeEntryAes256() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .encryptedLarge))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.stat().encryptionMethod, .aes256)
        try XCTAssertEqual(entry.data(password: Constants.password), .large)
    }

    func testCanReadArchiveComment() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .archiveComment))
        try XCTAssertEqual(zip.getComment(), Constants.archiveComment)
    }

    func testCanReadEntryComment() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .entryComment))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getComment(), Constants.entryComment)
    }

    func testCanReadExternalFieldFromLocalDirectory() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraSingleLocal))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 1)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldLocal)
    }

    func testCanReadExternalFieldFromCentralDirectory() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraSingleCentral))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 1)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldCentral)
    }

    func testCanReadExternalFieldFromBothDirectories() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraSingleBoth))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 2)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldCentral)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 1), .firstExtraFieldLocal)
    }

    func testCanReadMultipleExternalFieldsFromLocalDirectory() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraDoubleLocal))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 2)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldLocal)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 1), .firstExtraFieldLocal2)
    }

    func testCanReadMultipleExternalFieldsFromCentralDirectory() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraDoubleCentral))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 2)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldCentral)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 1), .firstExtraFieldCentral2)
    }

    func testCanReadMultipleExternalFieldsFromBothDirectories() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraDoubleBoth))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 4)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldCentral)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 1), .firstExtraFieldCentral2)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 2), .firstExtraFieldLocal)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 3), .firstExtraFieldLocal2)
    }

    func testCanReadDifferentExternalFieldsFromLocalDirectory() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraTwoLocal))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 1)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldLocal)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.secondExtraField), 1)
        try XCTAssertEqual(entry.getExtraField(id: Constants.secondExtraField, index: 0), .secondExtraField)
    }

    func testCanReadDifferentExternalFieldsFromCentralDirectory() throws {
        let zip = try ZipArchive(url: dataFileURL(for: .extraTwoCentral))
        let entry = try zip.locate(filename: Constants.entryName)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.firstExtraField), 1)
        try XCTAssertEqual(entry.getExtraField(id: Constants.firstExtraField, index: 0), .firstExtraFieldCentral)
        try XCTAssertEqual(entry.getExtraFieldsCount(id: Constants.secondExtraField), 1)
        try XCTAssertEqual(entry.getExtraField(id: Constants.secondExtraField, index: 0), .secondExtraField)
    }
}
