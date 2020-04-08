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

extension ZipSource {
    public convenience init(data: Data) throws {
        try self.init(callback: ZipSourceData(data: data))
    }
}

private final class ZipSourceData: ZipSourceSeekable {
    private let data: Data
    private var position: Int

    init(data: Data) {
        self.data = data
        self.position = 0
    }

    func open() {
        position = 0
    }

    func read(to buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
        guard count >= 0 else {
            throw ZipError.invalidArgument("count")
        }

        let available = min(count, data.count - position)
        data.subdata(in: position ..< position + available).withUnsafeBytes { data in
            _ = memmove(buffer, data.baseAddress.forceUnwrap(), data.count)
        }

        position += available
        return available
    }

    func close() {
    }

    func stat() -> ZipSourceStat {
        return ZipSourceStat(size: data.count)
    }

    func seek(offset: Int, whence: ZipWhence) throws {
        let newPosition: Int
        switch whence {
        case .set:
            newPosition = offset
        case .cur:
            newPosition = position + offset
        case .end:
            newPosition = data.count + offset
        default:
            throw ZipError.invalidArgument("offset")
        }

        guard newPosition >= 0 && newPosition <= data.count else {
            throw ZipError.invalidArgument("offset")
        }

        position = newPosition
    }

    func tell() -> Int {
        return position
    }
}
