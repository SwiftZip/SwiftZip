#!/bin/sh

# Pull the latest version if libzip
git submodule update --remote Sources/zip/libzip

# Copy `zip.h` and `zipconf.h` from libzip codebase to a separate include directory
# so Swift Package Manager can recognize public headers
cp Sources/zip/libzip/lib/zip.h Sources/zip/include/zip.h
cp Sources/zip/libzip/xcode/zipconf.h Sources/zip/include/zipconf.h

# Patch libzip header files to fix clang modular headers:
# - use `"..."` instead of `<...>` to include `zipconf.h`
# - use `stdint.h` instead of `inttypes.h`
patch Sources/zip/include/zip.h < Sources/zip/include-patches/zip.h.patch
patch Sources/zip/include/zipconf.h < Sources/zip/include-patches/zipconf.h.patch

# Check package build
swift build
