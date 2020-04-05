import Foundation

extension Data {
    public init(contentsOf entry: ZipEntry) throws {
        let size = try entry.stat().size
        var data = Data(count: Int(size))
        try data.withUnsafeMutableBytes { buffer in
            let file = try entry.open()
            try file.read(buf: buffer.baseAddress!, count: buffer.count)
            file.close()
        }

        self = data
    }
}

extension String {
    public init(contentsOf entry: ZipEntry, encoding: String.Encoding) throws {
        self = try String(data: Data(contentsOf: entry), encoding: encoding).unwrapped()
    }
}
