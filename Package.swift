// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Package definition

var package = Package(
    name: "SwiftZip",
    products: [
        .library(name: "zip", targets: ["zip"]),
        .library(name: "SwiftZip", targets: ["SwiftZip"]),
        .library(name: "SwiftZipUtils", targets: ["SwiftZipUtils"]),
    ],
    targets: [
        .target(
            name: "zip",
            path: "Sources/zip",
            exclude: flatten([
                // Common excluded items
                always(use: [
                    // Non-source directories
                    "libzip/android",
                    "libzip/cmake",
                    "libzip/cmake-compat",
                    "libzip/examples",
                    "libzip/man",
                    "libzip/regress",
                    "libzip/src",
                    "libzip/vstudio",

                    // Non-source files from root
                    "libzip/API-CHANGES.md",
                    "libzip/AUTHORS",
                    "libzip/INSTALL.md",
                    "libzip/LICENSE",
                    "libzip/NEWS.md",
                    "libzip/README.md",
                    "libzip/THANKS",
                    "libzip/TODO.md",
                    "libzip/CMakeLists.txt",
                    "libzip/appveyor.yml",
                    "libzip/cmake-config.h.in",
                    "libzip/cmake-zipconf.h.in",
                    "libzip/libzip-config.cmake.in",
                    "libzip/libzip.pc.in",
                    "libzip-patches",

                    // Non-source files from `developer-xcode`
                    "libzip/developer-xcode/extract-version.sh",
                    "libzip/developer-xcode/mkconfig-h.sh",
                    "libzip/developer-xcode/README Xcode Project.md",
                    "libzip/developer-xcode/Info.plist",

                    // Non-source files from `lib`
                    "libzip/lib/CMakeLists.txt",
                    "libzip/lib/make_zip_err_str.sh",
                    "libzip/lib/make_zipconf.sh",

                    // LZMA compression requires LZMA SDK
                    "libzip/lib/zip_algorithm_xz.c",
                    "libzip/lib/zip_algorithm_zstd.c",

                    // Alternative encryption SDKs
                    "libzip/lib/zip_crypto_gnutls.c",
                    "libzip/lib/zip_crypto_mbedtls.c",

                    // Windows UWP random generator
                    "libzip/lib/zip_random_uwp.c",
                ]),

                // Darwin-specific items
                when(HostPlatform.current != .darwin, use: [
                    // CommonCrypto
                    "libzip/lib/zip_crypto_commoncrypto.c",
                ]),

                // Exclude Linux-specific items
                when(HostPlatform.current != .linux, use: [
                    // OpenSSL crypto
                    "libzip/lib/zip_crypto_openssl.c",
                ]),

                // Exclude Windows-specific items
                when(HostPlatform.current != .windows, use: [
                    // Windows crypro
                    "libzip/lib/zip_crypto_win.c",

                    // Random generator
                    "libzip/lib/zip_random_win32.c",

                    // Utilities
                    "libzip/lib/zip_source_file_win32_ansi.c",
                    "libzip/lib/zip_source_file_win32_named.c",
                    "libzip/lib/zip_source_file_win32_utf8.c",
                    "libzip/lib/zip_source_file_win32_utf16.c",
                    "libzip/lib/zip_source_file_win32.c",
                ]),
            ]),
            sources: [
                "libzip/lib",
                "libzip/developer-xcode/zip_err_str.c",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .define("HAVE_CONFIG_H"),
                .headerSearchPath("libzip/lib"),
                .headerSearchPath("include-private"),
                .headerSearchPath("include-private/darwin", .when(platforms: [.macOS, .iOS, .tvOS, .watchOS])),
                .headerSearchPath("include-private/linux", .when(platforms: [.linux])),
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("bz2"),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("crypto", .when(platforms: [.linux])),
            ]
        ),
        .target(
            name: "SwiftZip",
            dependencies: ["zip"],
            path: "Sources/SwiftZip"
        ),
        .target(
            name: "SwiftZipUtils",
            dependencies: ["SwiftZip"],
            path: "Sources/SwiftZipUtils"
        ),
        .testTarget(
            name: "SwiftZipTests",
            dependencies: ["SwiftZip", "SwiftZipUtils"],
            path: "Tests/SwiftZipTests",
            resources: [.copy("Data")]
        ),
    ]
)

// MARK: - Current host platform

private enum HostPlatform: Equatable {
    case darwin
    case linux
    case windows

#if os(macOS)
    static let current = HostPlatform.darwin
#elseif os(Linux)
    static let current = HostPlatform.linux
#else
    #error("Unsupported host platform.")
#endif
}

// MARK: - Conditional array helpers

private func flatten<Element>(_ items: [[Element]]) -> [Element] {
    return items.flatMap { $0 }
}

private func always<Element>(use items: [Element]) -> [Element] {
    return items
}

private func when<Element>(_ condition: Bool, use items: [Element]) -> [Element] {
    if condition {
        return items
    } else {
        return []
    }
}
