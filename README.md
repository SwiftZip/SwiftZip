# SwiftZip

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
- `Sources/zip/include` contains public headers for the libzip as required by the Swift package manager
- `Sources/zip/include-patches` folder contains patches to be applied to the libzip header files, so they are compatible with the Swift package manager
- Swift wrappers are located under the `Sources/SwiftZip` directory and exposed as `SwiftZip` package

## Updating libzip
The SwiftZip wrapper is designed to make libzip updates as easy as possible. To update the underlying library, use the `update-libzip.sh` script to pull the latest version in the `Sources/zip/libzip` submodule and update public headers.

## TODO/Roadmap:
- [ ] provide an initial set of wrappers for archive operations
- [ ] cover core functionality with tests based on libzip test suite
- [ ] adapt libzip docs and convert them to code comments
- [ ] provide Swift protocol-based wrapper for custom sources API
- [ ] add macOS build support with external packages
- [ ] add Linux build support

## License
- libzip is released under a 3-clause BSD license: https://libzip.org/license/
- SwiftZip is published under an MIT license: https://github.com/SwiftZip/SwiftZip/blob/master/LICENSE
