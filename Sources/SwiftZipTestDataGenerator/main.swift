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

let testDataDirectory = URL(fileURLWithPath: #file)
    .deletingLastPathComponent() // Root/Sources/SwiftZipTestDataGenerator/
    .deletingLastPathComponent() // Root/Sources/
    .deletingLastPathComponent() // Root/
    .appendingPathComponent("Tests", isDirectory: true)
    .appendingPathComponent("SwiftZipTests", isDirectory: true)
    .appendingPathComponent("Data", isDirectory: true)

try FileManager.default.createDirectory(at: testDataDirectory, withIntermediateDirectories: true, attributes: nil)

func testFileURL(name: String) -> URL {
    return testDataDirectory.appendingPathComponent(name, isDirectory: false)
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "archive-comment.zip"), flags: [.create, .truncate])
    try zip.setComment(Constants.archiveComment)
    try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "entry-comment.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setComment(Constants.entryComment)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-single-local.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataLocal, flags: .local)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-single-central.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataCentral, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-single-both.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataLocal, flags: .local)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataCentral, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-double-local.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataLocal, flags: .local)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataCentral, flags: .local)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-double-central.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataLocal, flags: .central)
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataCentral, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-two-local.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataLocal, flags: .local)
    try entry.setExtraField(id: Constants.secondExtraField, index: nil, data: Constants.secondExtraFieldData, flags: .local)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "extra-two-central.zip"), flags: [.create, .truncate])
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setExtraField(id: Constants.firstExtraField, index: nil, data: Constants.firstExtraFieldDataLocal, flags: .central)
    try entry.setExtraField(id: Constants.secondExtraField, index: nil, data: Constants.secondExtraFieldData, flags: .central)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "simple-small.zip"), flags: [.create, .truncate])
    try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "simple-large.zip"), flags: [.create, .truncate])
    try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.largeData))
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "encrypted-small.zip"), flags: [.create, .truncate])
    try zip.setDefaultPassword("test password")
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.helloData))
    try entry.setEncryption(method: .aes192)
    try zip.close()
}

do {
    let zip = try ZipArchive(url: testFileURL(name: "encrypted-large.zip"), flags: [.create, .truncate])
    try zip.setDefaultPassword("test password")
    let entry = try zip.addFile(name: Constants.entryName, source: ZipSource(data: Constants.largeData))
    try entry.setEncryption(method: .aes256)
    try zip.close()
}
