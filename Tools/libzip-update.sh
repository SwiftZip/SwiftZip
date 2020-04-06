#!/bin/sh

# Pull the latest version if libzip
git submodule update --remote Sources/zip/libzip

# Copy `zip.h` and `zipconf.h` from libzip codebase to a separate include directory
# so Swift Package Manager can recognize public headers
cp Sources/zip/libzip/lib/zip.h Sources/zip/include/zip.h
cp Sources/zip/libzip/developer-xcode/zipconf.h Sources/zip/include/zipconf.h
cp Sources/zip/libzip/developer-xcode/config.h Sources/zip/include-private/config.h

# Patch libzip header files to fix clang modular headers:
# - use `"..."` instead of `<...>` to include `zipconf.h`
# - use `stdint.h` instead of `inttypes.h`
# - disable `HAVE_LIBLZMA` so we don't need to pull LZMA SDK
patch Sources/zip/include/zip.h < Sources/zip/libzip-patches/zip.h.patch
patch Sources/zip/include/zipconf.h < Sources/zip/libzip-patches/zipconf.h.patch
patch Sources/zip/include-private/darwin/config.h < Sources/zip/libzip-patches/config.h.darwin.patch
patch Sources/zip/include-private/linux/config.h < Sources/zip/libzip-patches/config.h.linux.patch

# Check package build
swift build
swift test
