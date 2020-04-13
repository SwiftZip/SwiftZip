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
    /// A platform-specific external attributes of the archive entry.
    public struct ExternalAttributes {
        public let operatingSystem: OperatingSystem
        public let attributes: UInt32
    }
}

// MARK: - Universal attributes

extension ZipEntry.ExternalAttributes {
    public var isDirectory: Bool {
        return posixFileType == S_IFDIR
    }

    public var isSymbolicLink: Bool {
        return posixFileType == S_IFLNK
    }
}

// MARK: - Parse POSIX attributes from platform-specific data

extension ZipEntry.ExternalAttributes {
    public var posixAttributes: mode_t {
        switch operatingSystem {
        case .dos,
             .vfat,
             .windowsNTFS:
            var attributes: mode_t = S_IRUSR | S_IRGRP | S_IROTH

            if attributes & 0x10 != 0 {
                // FILE_ATTRIBUTE_DIRECTORY
                attributes |= S_IFDIR
                attributes |= S_IXUSR | S_IXGRP | S_IXOTH
            }

            if attributes & 0x01 == 0 {
                /* FILE_ATTRIBUTE_READONLY */
                attributes |= S_IWUSR | S_IWGRP | S_IWOTH
            }

            return attributes

        case .unix,
             .macintosh,
             .macOS:
            return mode_t(attributes >> 16)

        default:
            assertionFailure("POSIX attributes requested for an unknown platform: `\(operatingSystem)`")
            return S_IRWXU | S_IRWXG | S_IRWXO
        }
    }

    public var posixPermissions: mode_t {
        return posixAttributes & (S_IRWXU | S_IRWXG | S_IRWXO)
    }

    public var posixFileType: mode_t {
        return posixAttributes & S_IFMT
    }
}
