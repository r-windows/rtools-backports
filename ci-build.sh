#!/bin/bash

# AppVeyor and Drone Continuous Integration for MSYS2
# Authors: Renato Silva, Qian Hong, Jeroen Ooms

# Setup git and CI
cd "$(dirname "$0")"
source 'ci-library.sh'
deploy_enabled && mkdir artifacts
deploy_enabled && mkdir sourcepkg

# msys64: remove preinstalled toolchains and swith to rtools40 repositories
pacman --noconfirm -Rcsu mingw-w64-{i686,x86_64}-toolchain gcc pkg-config
cp -f pacman.conf /etc/pacman.conf


pacman --noconfirm -Scc
pacman --noconfirm -Syyu
pacman --noconfirm --needed -S git base-devel binutils

# Install core build stuff
pacman --noconfirm --needed -S mingw-w64-{i686,x86_64}-{crt,winpthreads,gcc,libtre,pkg-config,xz}

# Initiate git
git_config user.email 'ci@msys2.org'
git_config user.name  'MSYS2 Continuous Integration'
git remote add upstream 'https://github.com/r-windows/rtools-backports'
git fetch --quiet upstream

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
export PKGEXT='.pkg.tar.xz'

for package in "${packages[@]}"; do
    execute 'Building binary' makepkg-mingw --noconfirm --noprogressbar --skippgpcheck --nocheck --syncdeps --rmdeps --cleanbuild
    execute 'Installing' yes:pacman --noprogressbar --upgrade *.pkg.tar.xz
    execute 'Checking Binaries' find ./pkg -regex ".*\.\(exe\|dll\|a\|pc\)"
    deploy_enabled && mv "${package}"/*.pkg.tar.xz artifacts
    unset package
done

# Deploy
deploy_enabled && cd artifacts || success 'All packages built successfully'
execute 'Generating pacman repository' create_pacman_repository "${PACMAN_REPOSITORY:-ci-build}"
execute 'Generating build references'  create_build_references  "${PACMAN_REPOSITORY:-ci-build}"
execute 'SHA-256 checksums' sha256sum *
success 'All artifacts built successfully'