#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

ELFUTILS_VERSION=${ELFUTILS_VERSION:-0.185}
ELFUTILS_URL="https://sourceware.org/elfutils/ftp/0.185/elfutils-${ELFUTILS_VERSION}.tar.bz2"
ELFUTILS_BUILD_DIR="${BUILD_DIRECTORY}/elfutils-build"
# temporary compat fix for the old build system
export ELFUTILS_DIR="/$(cc -dumpmachine)/usr"


# Requires:
# -zlib
# Building elfutils on musl seems to be a huge PITA:
# https://github.com/NixOS/nixpkgs/issues/68699
# Still trying...
build_elfutils() (
  curl -sLo 'elfutils.tar.bz2' "${ELFUTILS_URL}"
  common::extract 'elfutils.tar.bz2' "${ELFUTILS_BUILD_DIR}"
  common::safe_cd "${ELFUTILS_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${ELFUTILS_DIR_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls
  make -j"$(nproc)"
  make install

  echo "[+] Finished building elfutils for ${CURRENT_ARCH}"
)