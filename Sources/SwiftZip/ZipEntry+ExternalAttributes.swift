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

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Platform not supported")
#endif

extension ZipEntry {
    public struct ExternalAttributes {
        public let operatingSystem: OperatingSystem
        public let attributes: UInt32
    }
}

// MARK: - Platform-Specific Attribute Accessors

extension ZipEntry.ExternalAttributes {
    public var posixAttributes: mode_t {
        return mode_t(attributes >> 16)
    }

    public var posixPermissions: mode_t {
        return posixAttributes & (S_IRWXU | S_IRWXG | S_IRWXO)
    }

    public var posixFileType: mode_t {
        return posixAttributes & S_IFMT
    }
}

// MARK: - Universal Helpers

extension ZipEntry.ExternalAttributes {
    public var isDirectory: Bool {
        switch operatingSystem {
        case .dos,
             .windowsNTFS:
            return (attributes & 0x10) != 0

        case .unix,
             .macintosh,
             .macOS:
            return posixFileType == S_IFDIR

        default:
            return false
        }
    }

    public var isSymbolicLink: Bool {
        switch operatingSystem {
        case .unix,
             .macintosh,
             .macOS:
            return posixFileType == S_IFLNK

        default:
            return false
        }
    }
}
