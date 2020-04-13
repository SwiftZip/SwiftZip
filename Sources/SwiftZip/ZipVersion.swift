import zip

/// An accessor for libzip version information
public enum ZipVersion {
    /// Parserd libzip version for pattern matching
    public static let libzipVersion: (minor: Int, major: Int, micro: Int, suffix: String?) = preconditionNoThrow {
        let components = libzipVersionString.split(separator: ".")
        precondition(components.count == 3, "Invalid libzip version string: `\(libzipVersionString)`")

        if let suffixStart = components[2].firstIndex(where: { !$0.isNumber }) {
            return try (
                Int(components[0]).unwrapped(),
                Int(components[1]).unwrapped(),
                Int(components[2].prefix(upTo: suffixStart)).unwrapped(),
                String(components[2].suffix(from: suffixStart))
            )
        } else {
            return try (
                Int(components[0]).unwrapped(),
                Int(components[1]).unwrapped(),
                Int(components[2]).unwrapped(),
                nil
            )
        }
    }

    /// Raw libzip version string as reported by `zip_libzip_version`.
    public static let libzipVersionString = String(cString: zip_libzip_version())
}
