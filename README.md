# Overview

SwiftZip is a Swift wrapper for libzip providing an API to read, create and modify zip archives.
Files can be added from data buffers, files, or compressed data copied directly from other zip archives.
Changes made without closing the archive can be reverted.

## Installation

### Swift Package Manager

To depend on the SwiftZip package, you need to declare your dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/SwiftZip/SwiftZip.git", .branch("master")),
    // ...
]
```

and add "SwiftZip" to your application/library target dependencies, e.g. like this:

```swift
.target(name: "BestExampleApp", dependencies: [
    "SwiftZip",
    // ...
])
```

**Note:** SwiftZip is currently under development and API may slightly change as the project evolves.

### Using SwiftZip on Linux

SwiftZip requires `BZip2` and `OpenSSL` development packages to be installed when building on Linux.
You can install the required dependencies using `apt` on Ubuntu:

```bash
apt-get install libbz2-dev
apt-get install libssl-dev
```

## Getting Started

### Quick Instructions

Opening and inspecting an archive:

```swift
do {
    // Open an archive for reading
    let archive = try ZipArchive(url: archiveUrl)

    defer {
        // discard the archive when done
        archive.discard()
    }

    // Enumerate entries in the archive
    for entry in archive.entries {
        // Get basic entry information
        let name = try entry.getName()
        let size = try entry.stat().size
        print("\(name) -> \(size as Any)")

        // Read entry contents into a `Data` instance
        let data = try entry.data()
        print(data)
    }
} catch {
     // Handle possible errors
    print("\(error)")
}
```

Creating an archive:

```swift
do {
    // Open an archive for writing, overwriting any existing file
    let archive = try ZipArchive(url: archiveUrl, flags: [.create, .truncate])

    // Load the test data
    let data = try Data(contentsOf: dataUrl)

    // Create a data source and add it to the archive
    let source = try ZipSourceData(data: data)
    try archive.addFile(name: "filename.dat", source: source)

    // Commit changes and close the archive
    // Alternatively call `discard` to rollback any changes
    try archive.close()
} catch {
      // Handle possible errors
     print("\(error)")
}
```

## Getting More Help

SwiftZip is designed to be a thin wrapper aroung libzip. Please refer to the libzip documentation to get
more details on the underlying implementation: https://libzip.org/documentation/

# SwiftZip Project

SwiftZip in currently under development. Please open an issue or submit a pull request in case you find any
issues or have any improvement ideas.

## Project Goals
- the primary goal of the SwiftZip project is to provide first-class Swift bindings for libzip on all supported platforms
- the initial target is the iOS platform without any external dependencies,  macOS and Linux targets will be added later

## Design Considerations
- libzip must be included "as is" without any modifications to allow easy drop-in updates
- the library should be entirely opaque providing a native Swift interface for all libzip functionality
- the binding layer should propagate all underlying errors so client code can properly handle them

## Project Structure
- all libzip-related files are located under the `Sources/zip` directory and exposed as `zip` package
- `Sources/zip/libzip` is a submodule referencing relevant libzip source code
- `Sources/zip/libzip-patches` folder contains patches to be applied to the libzip header files, so they are compatible with the Swift package manager
- `Sources/zip/include` contains public headers for the libzip as required by the Swift package manager
- `Sources/zip/include-private` contains patched private headers to build libzip
- Swift wrappers are located under the `Sources/SwiftZip` directory and exposed as `SwiftZip` package

## Updating libzip
The SwiftZip wrapper is designed to make libzip updates as easy as possible.
To update the underlying library, use the `./Tools/libzip-update.sh` script to pull the latest version in
the `Sources/zip/libzip` submodule and update public headers.

## TODO/Roadmap:
- [ ] provide an initial set of wrappers for archive operations
- [ ] cover core functionality with tests based on libzip test suite
- [ ] adapt libzip docs and convert them to code comments
- [ ] provide Swift protocol-based wrapper for custom sources API
- [ ] add macOS build support with external packages
- [ ] add Linux build support

# License

- libzip is released under a 3-clause BSD license: https://libzip.org/license/
- SwiftZip is published under an MIT license: https://github.com/SwiftZip/SwiftZip/blob/master/LICENSE
