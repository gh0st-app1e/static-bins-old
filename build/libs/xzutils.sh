#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

XZUTILS_VERSION="${XZUTILS_VERSION:-5.8.0}"
XZUTILS_ARCHIVE="xz-${XZUTILS_VERSION}.tar.xz"
XZUTILS_URL="https://sourceforge.net/projects/lzmautils/files/${XZUTILS_ARCHIVE}/download"
XZUTILS_BUILD_DIR="${BUILD_DIRECTORY}/xzutils-build"
# temporary compat fix for the old build system
export XZUTILS_DIR="/$(cc -dumpmachine)/usr"


build_liblzma() (
  curl -sLo "${XZUTILS_ARCHIVE}" "${XZUTILS_URL}"
  common::extract "${XZUTILS_ARCHIVE}" "${XZUTILS_BUILD_DIR}"
  common::safe_cd "${XZUTILS_BUILD_DIR}"

  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${XZUTILS_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls \
      --disable-doc \
      --disable-xz \
      --disable-xzdec \
      --disable-lzmadec \
      --disable-lzmainfo \
      --disable-lzma-links \
      --disable-scripts
  make -j"$(nproc)"
  make install

  echo "[+] Finished building liblzma for ${CURRENT_ARCH}"
)