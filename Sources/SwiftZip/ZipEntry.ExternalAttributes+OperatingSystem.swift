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

extension ZipEntry.ExternalAttributes {
    public struct OperatingSystem: RawRepresentable, Equatable {
        public let rawValue: UInt8
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let dos = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_DOS))
        public static let amiga = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_AMIGA))
        public static let openVMS = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_OPENVMS))
        public static let unix = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_UNIX))
        public static let vmCMS = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_VM_CMS))
        public static let atariST = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_ATARI_ST))
        public static let os2 = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_OS_2))
        public static let macintosh = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_MACINTOSH))
        public static let zSystem = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_Z_SYSTEM))
        public static let cpm = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_CPM))
        public static let windowsNTFS = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_WINDOWS_NTFS))
        public static let mvs = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_MVS))
        public static let vse = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_VSE))
        public static let acornRISC = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_ACORN_RISC))
        public static let vfat = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_VFAT))
        public static let alternateMVS = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_ALTERNATE_MVS))
        public static let beOS = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_BEOS))
        public static let tandem = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_TANDEM))
        public static let os400 = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_OS_400))
        public static let macOS = OperatingSystem(rawValue: UInt8(ZIP_OPSYS_OS_X))
    }
}
