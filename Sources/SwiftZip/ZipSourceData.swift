import Foundation

public final class ZipSourceData: ZipSource {
    private let data: NSData

    public init(data: Data) throws {
        self.data = data as NSData
        try super.init(buffer: self.data.bytes, length: self.data.length, freeWhenDone: false)
    }
}
