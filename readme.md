# Rtools Backports [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/rtools-backports?branch=master)](https://ci.appveyor.com/project/jeroen/rtools-backports)

Backported libraries with the Rtools35 gcc-4.9.3 legacy toolchain.

## What is this

We are currently migrating R on Windows to a new GCC 8+ toolchain and build system called rtools40. This new system enables us to automatically build and distribute external C/C++ libs needed for building R packages.

However for the foreseeable future we also want to keep supporting the older versions of R on Windows that use the gcc-4.9.3 toolchain from Rtools35. Because some C/C++ libs (not all) are ABI sensitive, they need to be recompiled with the same toolchain that is used to compile the R package. This is what the libraries in `rtools-backports` are used for.

## How it works

The CI in this repository uses the new rtools40 build environment and dependencies from the [rtools-packages](https://github.com/r-windows/rtools-packages) repo. However for packages in `rtools-backports`, we manually override the build scripts to use compilers from Rtools35 by setting `CC` and `CXX` environment variables in the PKGBUILD files. Thereby the libs get compiled with gcc-4.9.3 and the resulting binaries can be used to build R packages with the old toolchain.

Rtools35 did not include a package manager so these libs are not automatically deployed anywhere. Upon success, you can download the binaries from appveyor artifacts or [bintray](http://dl.bintray.com/rtools/backports/). We manually test them (by building the R package), and if they seem OK we may host a copy of the binaries in the [rwinlib](https://github.com/rwinlib) organization on Github.

Yes this is all a bit hacky, hopefully the gcc 4.9.3 toochain will be phased out soon.
