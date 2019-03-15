# Rtools Backports [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/rtools-backports?branch=master)](https://ci.appveyor.com/project/jeroen/rtools-backports)

Attempts to backport libs with the old Rtools35 gcc-4.9.3 toolchain.

## What is this

The CI uses the rtools40 build environment and dependencies from the [rtools-packages](https://github.com/r-windows/rtools-packages) repo. We then override the default compiler by setting `CC`, `CXX` and so on. This method super hacky and may not work for all libraries, in particular if the library has C++ dependencies that rely on the new ABI.

Hopefully the gcc 4.9.3 toochain will be phased out soon.

We do not deploy these anywhere. Upon success, you can download the binaries from appveyor artifacts. If they seem to work, you can consider hosting the binaries on https://github.com/rwinlib.
