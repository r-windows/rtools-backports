# Rtools Backports [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/rtools-backports?branch=master)](https://ci.appveyor.com/project/jeroen/rtools-backports)

Backported libraries with the Rtools35 gcc-4.9.3 legacy toolchain.

## What is this

As of version 4.0 (April 2020), R on Windows switched to a new build system called rtools40, which includes at a toolchain based on GCC-8. This new system enables us to automatically build and distribute external C/C++ libs needed for building R packages.

However for legacy users we also try to keep supporting R for Windows versions 3.3-3.6 which use the gcc-4.9.3 toolchain from Rtools35. Because some C/C++ libraries are ABI sensitive, these need to be compiled with the same toolchain that is used to compile the R package. This is what the binaries in `rtools-backports` are used for.

## How it works

The CI in this repository uses the regular rtools40 build environment and dependencies from the [rtools-packages](https://github.com/r-windows/rtools-packages) repo. However for packages in `rtools-backports`, we manually override the build scripts to use compilers from Rtools35 by setting `CC` and `CXX` environment variables in the PKGBUILD files. Thereby the libs get compiled with gcc-4.9.3 and the resulting binaries can be used to build R packages with the old toolchain.

Rtools35 did not include a package manager so these libs are not automatically deployed anywhere. Upon success, you can download the binaries from appveyor artifacts or [bintray](http://dl.bintray.com/rtools/backports/). We manually test them (by building the R package), and if they seem OK we may host a copy of the binaries in the [rwinlib](https://github.com/rwinlib) organization on Github.

This is all a bit hacky, we try to keep it working on a best effort basis. Users are very much recommended to upgrade to R 4.0 or newer!
