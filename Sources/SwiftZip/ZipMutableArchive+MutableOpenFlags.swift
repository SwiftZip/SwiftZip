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

import zip

extension ZipMutableArchive {
    /// A set of flags to be used with `ZipMutableArchive.init`.
    public struct MutableOpenFlags: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ZipMutableArchive.MutableOpenFlags {
    /// Perform additional stricter consistency checks on the archive, and error if they fail.
    public static let checkConsistency = ZipMutableArchive.MutableOpenFlags(rawValue: ZIP_CHECKCONS)

    /// Create the archive if it does not exist.
    public static let create = ZipMutableArchive.MutableOpenFlags(rawValue: ZIP_CREATE)

    /// Error if archive already exists.
    public static let exclusive = ZipMutableArchive.MutableOpenFlags(rawValue: ZIP_EXCL)

    /// If archive exists, ignore its current contents. In other words, handle it the same way as an empty archive.
    public static let truncate = ZipMutableArchive.MutableOpenFlags(rawValue: ZIP_TRUNCATE)
}
