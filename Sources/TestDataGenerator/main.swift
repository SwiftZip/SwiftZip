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

let testDataDirectory = URL(fileURLWithPath: #file)
    .deletingLastPathComponent() // Root/Sources/SwiftZipTestDataGenerator/
    .deletingLastPathComponent() // Root/Sources/
    .deletingLastPathComponent() // Root/
    .appendingPathComponent("Tests", isDirectory: true)
    .appendingPathComponent("SwiftZipTests", isDirectory: true)
    .appendingPathComponent("Data", isDirectory: true)

try FileManager.default.createDirectory(at: testDataDirectory, withIntermediateDirectories: true, attributes: nil)

func testFileURL(for archive: TestArchive) -> URL {
    return testDataDirectory.appendingPathComponent(archive.rawValue, isDirectory: false)
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .simpleSmall), flags: [.create, .truncate])
    try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .simpleLarge), flags: [.create, .truncate])
    try zip.addFile(name: Constants.entryName, source: ZipSource(data: .large))
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .modifiedDate), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setModifiedDate(Constants.modifiedDate)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .externalAttributes), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExternalAttributes(operatingSystem: Constants.externalSystem, attributes: Constants.externalAttributes)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .encryptedSmall), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setEncryption(method: .aes192, password: Constants.password)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .encryptedLarge), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .large))
    try entry.setEncryption(method: .aes256, password: Constants.password)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .archiveComment), flags: [.create, .truncate])
    try zip.setComment(Constants.archiveComment)
    try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .entryComment), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setComment(Constants.entryComment)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraSingleLocal), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal, flags: .local)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraSingleCentral), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraSingleBoth), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal, flags: .local)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraDoubleLocal), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal, flags: .local)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal2, flags: .local)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraDoubleCentral), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral, flags: .central)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral2, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraDoubleBoth), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal, flags: .local)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal2, flags: .local)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral, flags: .central)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral2, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraTwoLocal), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldLocal, flags: .local)
    try entry.setExtraField(id: Constants.secondExtraField, index: nil, data: .secondExtraField, flags: .local)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .extraTwoCentral), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .hello))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: .firstExtraFieldCentral, flags: .central)
    try entry.setExtraField(id: Constants.secondExtraField, index: nil, data: .secondExtraField, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipMutableArchive(url: testFileURL(for: .largeForExport), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: .large))
    try entry.setModifiedDate(Constants.modifiedDate)
    try entry.setExternalAttributes(posixAttributes: Constants.posixPermissions)
    try zip.close()
}
