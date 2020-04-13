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
    /// A collection of mutable entries in the archive.
    public final class MutableEntryCollection {
        internal let archive: ZipMutableArchive

        internal init(archive: ZipMutableArchive) {
            self.archive = archive
        }
    }
}

extension ZipMutableArchive.MutableEntryCollection: RandomAccessCollection {
    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return assertNoThrow(or: 0) {
            try archive.getEntryCount(version: .current)
        }
    }

    public subscript(position: Int) -> ZipMutableEntry {
        return preconditionNoThrow {
            try archive.getMutableEntry(index: position)
        }
    }
}

extension ZipMutableArchive {
    /// Exposes the original unmodified archive entries as a Swift `Collection`
    public var unchangedEntries: EntryCollection {
        return entries(version: .unchanged)
    }

    /// Exposes mutable archive entries as a Swift `Collection`
    public var mutableEntries: MutableEntryCollection {
        return MutableEntryCollection(archive: self)
    }
}
