#!/bin/sh

diff -u Sources/zip/libzip/lib/zip.h Sources/zip/include/zip.h > Sources/zip/libzip-patches/zip.h.patch
diff -u Sources/zip/libzip/developer-xcode/zipconf.h Sources/zip/include/zipconf.h > Sources/zip/libzip-patches/zipconf.h.patch
diff -u Sources/zip/libzip/developer-xcode/config.h Sources/zip/include-private/darwin/config.h > Sources/zip/libzip-patches/config.h.darwin.patch
diff -u Sources/zip/libzip/developer-xcode/config.h Sources/zip/include-private/linux/config.h > Sources/zip/libzip-patches/config.h.linux.patch
