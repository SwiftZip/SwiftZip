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

private struct Platform: OptionSet {
    let rawValue: UInt

    static let macOS = Platform(rawValue: 1 << 0)
    static let iOS = Platform(rawValue: 1 << 1)
    static let tvOS = Platform(rawValue: 1 << 2)
    static let watchOS = Platform(rawValue: 1 << 3)
    static let linux = Platform(rawValue: 1 << 4)
    static let windows = Platform(rawValue: 1 << 5)

    static let darwinFamily: Platform = [.macOS, .iOS, .tvOS, .watchOS]
    static let linuxFamily: Platform = [.linux]
    static let windowsFamily: Platform = [.windows]

    #if os(macOS)
    static let current = Platform.macOS
    #elseif os(iOS)
    static let current = Platform.iOS
    #elseif os(tvOS)
    static let current = Platform.tvOS
    #elseif os(watchOS)
    static let current = Platform.watchOS
    #elseif os(Linux)
    static let current = Platform.linux
    #elseif os(Windows)
    static let current = Platform.windows
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
                    // Exclude LZMA compression for Darwin
                    "libzip/lib/zip_algorithm_xz.c",

                    // Exclude alternative encryption
                    "libzip/lib/zip_crypto_gnutls.c",
                    "libzip/lib/zip_crypto_mbedtls.c",

                    // Exclude Windows UWP random
                    "libzip/lib/zip_random_uwp.c",
                ]),

                // Exclude Darwin-specific items
                when(Platform.current.isDisjoint(with: .darwinFamily), use: [
                    // CommonCrypto
                    "libzip/lib/zip_crypto_commoncrypto.c",
                ]),

                // Exclude Linux-specific items
                when(Platform.current.isDisjoint(with: .linuxFamily), use: [
                    // OpenSSL crypto
                    "libzip/lib/zip_crypto_openssl.c",
                ]),

                // Exclude Windows-specific items
                when(Platform.current.isDisjoint(with: .windowsFamily), use: [
                    // Windows crypro
                    "libzip/lib/zip_crypto_win.c",

                    // Windows random
                    "libzip/lib/zip_random_win32.c",

                    // Windows utilities
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
                when(Platform.current.isSubset(of: .darwinFamily), use: [
                    .headerSearchPath("include-private/darwin"),
                ]),

                // Linux-specific settings
                when(Platform.current.isSubset(of: .linuxFamily), use: [
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
                when(Platform.current.isSubset(of: .linuxFamily), use: [
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
