// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private func execute<T>(_ block: () -> T) -> T {
    return block()
}

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

private enum Platform: Equatable {
    case darwin
    case linux
    case windows

    #if os(macOS)
    static let current = Platform.darwin
    #elseif os(Linux)
    static let current = Platform.linux
    #else
    #error("Unsupported platform.")
    #endif
}

let package = Package(
    name: "SwiftZip",
    products: [
        .library(name: "zip", targets: ["zip"]),
        .library(name: "SwiftZip", targets: ["SwiftZip"]),
    ],
    targets: [
        .target(
            name: "zip",
            path: "Sources/zip",
            exclude: flatten([
                // Common excluded items
                always(use: [
                    // Non-source files
                    "libzip/lib/CMakeLists.txt",
                    "libzip/lib/make_zip_err_str.sh",
                    "libzip/lib/make_zipconf.sh",

                    // LZMA compression requires LZMA SDK
                    "libzip/lib/zip_algorithm_xz.c",

                    // Alternative encryption SDKs
                    "libzip/lib/zip_crypto_gnutls.c",
                    "libzip/lib/zip_crypto_mbedtls.c",

                    // Windows UWP random generator
                    "libzip/lib/zip_random_uwp.c",
                ]),

                // Exclude Darwin-specific items
                when(Platform.current != .darwin, use: [
                    // CommonCrypto
                    "libzip/lib/zip_crypto_commoncrypto.c",
                ]),

                // Exclude Linux-specific items
                when(Platform.current != .linux, use: [
                    // OpenSSL crypto
                    "libzip/lib/zip_crypto_openssl.c",
                ]),

                // Exclude Windows-specific items
                when(Platform.current != .windows, use: [
                    // Windows crypro
                    "libzip/lib/zip_crypto_win.c",

                    // Random generator
                    "libzip/lib/zip_random_win32.c",

                    // Utilities
                    "libzip/lib/zip_source_win32a.c",
                    "libzip/lib/zip_source_win32handle.c",
                    "libzip/lib/zip_source_win32utf8.c",
                    "libzip/lib/zip_source_win32w.c",
                ]),
            ]),
            sources: [
                "libzip/lib",
            ],
            publicHeadersPath: "include",
            cSettings: flatten([
                // Common settings
                always(use: [
                    .define("HAVE_CONFIG_H"),
                    .headerSearchPath("include-private"),
                ]),

                // Darwin-specific settings
                when(Platform.current == .darwin, use: [
                    .headerSearchPath("include-private/darwin"),
                ]),

                // Linux-specific settings
                when(Platform.current == .linux, use: [
                    .headerSearchPath("include-private/linux"),
                ]),
            ]),
            linkerSettings: flatten([
                // Common settings
                always(use: [
                    .linkedLibrary("z"),
                    .linkedLibrary("bz2"),
                ]),

                // Linux-specific linker settings
                when(Platform.current == .linux, use: [
                    .linkedLibrary("ssl"),
                    .linkedLibrary("crypto")
                ]),
            ])
        ),
        .target(
            name: "SwiftZip",
            dependencies: ["zip"],
            path: "Sources/SwiftZip"
        ),
        .testTarget(
            name: "SwiftZipTests",
            dependencies: ["SwiftZip"],
            path: "Tests/SwiftZipTests"
        ),
    ]
)
