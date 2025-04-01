#!/bin/bash
set -euxo pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

UTIL_LINUX_VERSION_MAJOR="${UTIL_LINUX_VERSION_MAJOR:-2}"
UTIL_LINUX_VERSION_MINOR="${UTIL_LINUX_VERSION_MINOR:-37}"
UTIL_LINUX_VERSION_MAINTENANCE="${UTIL_LINUX_VERSION_MAINTENANCE:-1}"
if [ -z "${UTIL_LINUX_VERSION_MAINTENANCE}" ]; then
  UTIL_LINUX_VERSION="${UTIL_LINUX_VERSION_MAJOR}.${UTIL_LINUX_VERSION_MINOR}"
else
  UTIL_LINUX_VERSION="${UTIL_LINUX_VERSION_MAJOR}.${UTIL_LINUX_VERSION_MINOR}.${UTIL_LINUX_VERSION_MAINTENANCE}"
fi
UTIL_LINUX_URL="https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${UTIL_LINUX_VERSION_MAJOR}.${UTIL_LINUX_VERSION_MINOR}/util-linux-${UTIL_LINUX_VERSION}.tar.xz"
UTIL_LINUX_BUILD_DIR="${BUILD_DIRECTORY}/util-linux-build"
# temporary compat fix for the old build system
export UTIL_LINUX_DIR="/$(cc -dumpmachine)/usr"


# util-linux contains a LOT of stuff, separate recipes will be used to compile different parts.
# WARNING: running tests may be dangerous, see https://www.linuxfromscratch.org/lfs/view/9.0/chapter06/util-linux.html
# May depend on:
# - binutils
# - coreutils
# - diffutils
# - gettext
# - ncurses
# - zlib


# Should not depend on anything.
build_libuuid() (
  curl -sLo 'util-linux.tar.xz' "${UTIL_LINUX_URL}"
  common::extract 'util-linux.tar.xz' "${UTIL_LINUX_BUILD_DIR}"
  common::safe_cd "${UTIL_LINUX_BUILD_DIR}"
  
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --host="$(build::get_host_triplet)" \
      --disable-dependency-tracking \
      --prefix="${UTIL_LINUX_DIR}" \
      --disable-shared \
      --enable-static \
      --disable-nls \
      --disable-asciidoc \
      --disable-all-programs \
      --enable-libuuid
  make -j"$(nproc)"
  make install

  echo "[+] Finished building util-linux for ${CURRENT_ARCH}"
)