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
import SwiftZipUtils
import XCTest

class FilesystemExportTests: ZipTestCase {
    func testCanSaveEntryToFile() throws {
        let fileUrl = tempFileURL(ext: "txt")
        let zip = try ZipArchive(url: dataFileURL(for: .largeForExport))
        let entry = try zip.locate(filename: Constants.entryName)
        try entry.save(to: fileUrl)
        try XCTAssertEqual(Data(contentsOf: fileUrl), .large)

        let attributes = try FileManager.default.attributesOfItem(atPath: fileUrl.absoluteURL.path)

        if let posixPermissions = attributes[.posixPermissions] as? mode_t {
            XCTAssertEqual(posixPermissions, Constants.posixPermissions)
        } else {
            XCTFail("Failed to read POSIX permissions of `\(fileUrl.absoluteURL.path)`")
        }

#if !os(Linux)
        if let modificationDate = attributes[.modificationDate] as? Date {
            XCTAssertEqual(
                modificationDate.timeIntervalSinceReferenceDate,
                Constants.modifiedDate.addingTimeInterval(-TimeInterval(NSTimeZone.system.secondsFromGMT())).timeIntervalSinceReferenceDate,
                accuracy: 0.001)
        } else {
            XCTFail("Failed to read modification date of `\(fileUrl.absoluteURL.path)`")
        }
#endif
    }
}
