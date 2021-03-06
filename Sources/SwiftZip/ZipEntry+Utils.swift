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

extension ZipEntry {
    /// Retrieves entry contents as `Data` instance.
    ///
    /// - Parameters:
    ///   - flags: open flags, defaults to `[]`
    ///   - password: optional password to decrypt the entry
    public func data(flags: OpenFlags = [], password: String? = nil) throws -> Data {
        let size = try stat().size.unwrapped()
        var data = Data(count: Int(size))
        try data.withUnsafeMutableBytes { buffer in
            let file = try open(flags: flags, password: password)
            let read = try file.read(buf: buffer.baseAddress.forceUnwrap(), count: buffer.count)
            assert(read == buffer.count, "Failed to read \(buffer.count) bytes. Got \(read) instead.")
            file.close()
        }

        return data
    }
}
