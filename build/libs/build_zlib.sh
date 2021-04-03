#!/bin/bash
set -e
set -x
set -o pipefail

. "${GITHUB_WORKSPACE}/build/common_lib.sh"
. "${GITHUB_WORKSPACE}/build/build_lib.sh"

# Only the latest release is available at zlib.net
ZLIB_VERSION='1.2.11'
ZLIB_URL="https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz"
ZLIB_BUILD_DIR="${BUILD_DIRECTORY}/zlib-src"
export ZLIB_DIR="${BUILD_DIRECTORY}/zlib"


build_zlib() (
  curl -so 'zlib.tar.gz' "${ZLIB_URL}"
  common::extract 'zlib.tar.gz' "${ZLIB_BUILD_DIR}"
  common::safe_cd "${ZLIB_BUILD_DIR}"

  make distclean
  # Does not have --host option, use CHOST instead
  #   (but we won't need it - in our container cross compiler is the default one).
  CFLAGS="${GCC_OPTS}" \
    CXXFLAGS="${GXX_OPTS}" \
    ./configure \
      --prefix="${ZLIB_DIR}" \
      --static
  make -j4
  make install

  echo "[+] Finished building zlib for ${CURRENT_ARCH}"
)