#!/bin/bash

# AppVeyor and Drone Continuous Integration for MSYS2
# Authors: Renato Silva, Qian Hong, Jeroen Ooms

# Setup git and CI
cd "$(dirname "$0")"
source 'ci-library.sh'
mkdir artifacts
mkdir sourcepkg
git_config user.email 'ci@msys2.org'
git_config user.name  'MSYS2 Continuous Integration'
git remote add upstream 'https://github.com/r-windows/rtools-backports'
git fetch --quiet upstream

# Remove toolchain packages (preinstalled on AppVeyor)
pacman --noconfirm -Rcsu mingw-w64-{i686,x86_64}-toolchain gcc pkg-config

# Set build repositories
cp -f pacman.conf /etc/pacman.conf
pacman --noconfirm -Scc
pacman --noconfirm -Syyuu

# Install core build stuff
pacman --noconfirm -S mingw-w64-{i686,x86_64}-{gcc,pkg-config,xz}

# Detect changed packages
list_commits  || failure 'Could not detect added commits'
list_packages || failure 'Could not detect changed files'
message 'Processing changes' "${commits[@]}"
test -z "${packages}" && success 'No changes in package recipes'
define_build_order || failure 'Could not determine build order'

# Build
message 'Building packages' "${packages[@]}"
execute 'Approving recipe quality' check_recipe_quality

# Force static linking
rm -f /mingw32/lib/*.dll.a
rm -f /mingw64/lib/*.dll.a
export PKG_CONFIG="/${MINGW_INSTALLS}/bin/pkg-config --static"

for package in "${packages[@]}"; do
    execute 'Building binary' makepkg-mingw --noconfirm --noprogressbar --skippgpcheck --nocheck --syncdeps --rmdeps --cleanbuild
    execute 'Installing' yes:pacman --noprogressbar --upgrade *.pkg.tar.xz
    execute 'Checking Binaries' find ./pkg -regex ".*\.\(exe\|dll\|a\|pc\)"
    mv "${package}"/*.pkg.tar.xz artifacts
    unset package
done

success 'Great success!'
