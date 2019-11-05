import Foundation
import XCTest
import SwiftZip

class BaseTestCase: XCTestCase {
    private static let tempRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
    private static let tempDirectory = tempRoot.appendingPathComponent(UUID().uuidString, isDirectory: true)

    override class func setUp() {
        super.setUp()
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        print(tempDirectory)
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
}
